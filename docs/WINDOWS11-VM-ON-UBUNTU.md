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
