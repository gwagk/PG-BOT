# Windows 11 VM on Ubuntu — KVM/QEMU

> บันทึกจากการทำจริง 25 Sep 2026  
> ใช้เป็นสนามทดสอบ Windows สำหรับ PG-BOT โดยไม่แตะเครื่องราชการจริง

## เป้าหมาย

สร้าง Windows 11 Virtual Machine บน Ubuntu แบบลีน ด้วย **KVM/QEMU + libvirt + virt-manager**  
VM ทดสอบของเราใช้ชื่อ **WIN11-PGB**

## 1. ตรวจ Virtualization

```bash
lscpu | grep -E 'Virtualization|VT-x|AMD-V'
ls -l /dev/kvm
```

เครื่องที่ทำครั้งนี้พบ `VT-x` และ `/dev/kvm` พร้อมใช้งาน

## 2. ติดตั้ง KVM / libvirt / virt-manager

บน Ubuntu รุ่นที่ใช้ครั้งนี้ `qemu-kvm` เป็น virtual package จึงติดตั้ง `qemu-system-x86` โดยตรง

```bash
sudo apt update
sudo apt install -y qemu-system-x86 libvirt-daemon-system libvirt-clients virt-manager
```

เปิด libvirt:

```bash
sudo systemctl enable --now libvirtd
systemctl status libvirtd --no-pager
```

## 3. เพิ่มสิทธิ์ผู้ใช้

```bash
sudo usermod -aG libvirt,kvm $USER
```

Logout/Login หรือ reboot หนึ่งครั้ง แล้วตรวจ:

```bash
groups
```

ต้องเห็น `libvirt` และ `kvm`

## 4. เปิด Virtual Machine Manager

```bash
virt-manager
```

สถานะ QEMU/KVM ต้อง Connected

## 5. เตรียม Windows 11 ISO

ใช้ Windows 11 x64 ISO จาก Microsoft โดยตรง  
ไฟล์ที่ใช้ในการทดสอบ:

```text
Win11_25H2_EnglishInternational_x64_v2.iso
```

เลือกใน virt-manager:

`Create new VM → Local install media → Browse Local → Windows ISO`

## 6. ค่าของ VM ที่ใช้จริง

| รายการ | ค่า |
|---|---|
| OS | Windows 11 |
| RAM | 8192 MiB |
| CPU | 4 |
| Virtual Disk | 64 GiB (qcow2 / sparse) |
| Chipset | Q35 |
| Firmware | UEFI |
| TPM | Emulated / CRB / 2.0 |
| VM / Computer Name | WIN11-PGB |

> 64 GiB เป็นขนาด logical ของ sparse disk ไม่ได้ใช้พื้นที่ Host 64 GiB ทันที แต่ไฟล์จะโตตามข้อมูลที่เขียนจริง ต้องเฝ้าพื้นที่ว่างของ Ubuntu

## 7. TPM 2.0

ก่อนติดตั้งเลือก `Customize configuration before install`

ที่ TPM:

```text
Type    : Emulated
Model   : CRB
Version : 2.0
```

จากนั้น Begin Installation

## 8. ถ้า ISO ไม่ Boot ครั้งแรก

ถ้า UEFI DVD-ROM ขึ้น Timeout ให้เข้า Boot Menu แล้วเลือก:

```text
UEFI QEMU DVD-ROM
```

เมื่อขึ้น `Press any key to boot from CD or DVD...` ให้กดปุ่มทันที

## 9. ติดตั้ง Windows

สำหรับสนามทดสอบครั้งนี้:

- Edition: Windows 11 Pro
- Product Key: สามารถเลือก `I don't have a product key` สำหรับ VM ทดสอบ
- Disk: เลือก `Disk 0 Unallocated Space` แล้ว Next ให้ Windows สร้าง partition เอง
- หลัง reboot อย่ากดปุ่มเพื่อ boot ISO ซ้ำ
- ตั้ง Computer Name: `WIN11-PGB`

## 10. คืนเมาส์จาก VM

ถ้าเมาส์/คีย์บอร์ดถูก VM จับไว้ ใช้:

```text
Super + Esc
```

## 11. เป้าหมายการทดสอบ PG-BOT

หลัง Windows พร้อม ให้รัน PG-BOT และตรวจว่า `PG-BOT-LAST.txt` แสดง:

```text
COMPUTER NAME : WIN11-PGB
```

เมื่อค่าตรงกับชื่อเครื่อง ถือว่าฟังก์ชัน Computer Name ผ่านการทดสอบ

---

## หลักการ

**Test in VM first → ผ่านแล้วค่อยใช้กับเครื่องจริง**

VM นี้ตั้งใจให้เป็น Windows sandbox สำหรับทดสอบ PG-BOT, batch/script และการเปลี่ยนแปลงรุ่นถัดไป โดยลดความเสี่ยงต่อเครื่องงานจริง


---

## Incident / Lesson Learned — Host disk full

ระหว่างติดตั้ง Windows 11 พบว่า Ubuntu root partition มีขนาดประมาณ **73 GiB** และก่อนเริ่มมีพื้นที่ว่างประมาณ **22 GiB** ขณะที่ `win11.qcow2` แม้ตั้ง logical size ไว้ 64 GiB แบบ sparse แต่โตจริงจนประมาณ **23 GiB** ทำให้ root filesystem ขึ้น **99–100%** และเหลือพื้นที่ประมาณ 1 GiB

จุดตรวจที่ใช้:

```bash
df -h /
sudo du -h /var/lib/libvirt/images/win11.qcow2
sudo du -xhd1 /var 2>/dev/null | sort -h
sudo du -xhd1 /var/lib 2>/dev/null | sort -h
lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID,MOUNTPOINTS
```

ผลสำคัญของเครื่องทดสอบ:

- Ubuntu อยู่บน `nvme0n1p7` ext4 ประมาณ 73 GiB
- `/var/lib/libvirt` ใช้ประมาณ 23 GiB โดยหลักคือ `win11.qcow2`
- `/var/lib/snapd` ประมาณ 6.2 GiB
- SSD ทั้งลูกประมาณ 477 GiB และยังมี Windows OEM / recovery เดิมอยู่
- มี partition D: ขนาดประมาณ 228.8 GiB ซึ่งต้องตรวจสถานะและข้อมูลให้ชัดก่อนปรับ partition

### กฎเหล็กระหว่างกู้พื้นที่

**ห้ามเปิด WIN11-PGB VM จนกว่าจะย้าย/ขยายพื้นที่ Linux สำเร็จ และตรวจแล้วว่า Host มีพื้นที่ว่างปลอดภัย**

ไม่ลบ `win11.qcow2` เพราะ Windows VM ติดตั้งไปเกือบเสร็จแล้ว และไม่แตะ Windows OEM / WinRE / Recovery โดยไม่จำเป็น

### แผนถัดไป

เครื่องนี้ใช้งาน Ubuntu มากกว่า Windows จึงวางแผนให้ **Linux เป็นระบบหลักและมีพื้นที่มากขึ้น แต่เก็บ Windows OEM เดิมไว้**

ลำดับงานที่ตั้งใจทำ:

1. ตรวจสถานะ D: และ BitLocker/Device Encryption ให้แน่ชัด
2. ตรวจข้อมูลและพื้นที่ว่างของ D:
3. สำรองข้อมูลสำคัญก่อนแก้ partition
4. ลด/จัดสรรพื้นที่จาก D: และสร้างพื้นที่ Linux แบบ ext4
5. ย้าย/ขยาย Ubuntu ไปยังพื้นที่ใหม่
6. ตรวจ UUID, `/etc/fstab`, UEFI/GRUB และการบูต
7. ทดสอบให้ Ubuntu และ Windows OEM บูตได้ทั้งคู่
8. ตรวจ `df -h /` ว่ามีพื้นที่ปลอดภัย
9. หลังทุกอย่างผ่านแล้วจึงอนุญาตให้เปิด `WIN11-PGB` อีกครั้ง

### บทเรียน

**Sparse qcow2 ไม่ได้แปลว่าใช้พื้นที่น้อยเสมอไป** — มันเพียงไม่จองเต็ม logical size ตั้งแต่ต้น แต่จะโตตามข้อมูลจริงของ Guest OS ดังนั้นก่อนสร้าง Windows VM ต้องดู **free space ของ Host** ไม่ใช่ดูแค่ virtual disk size และควรเผื่อพื้นที่สำหรับ Windows Update, temporary files, snapshots และการเติบโตของ VM ด้วย
