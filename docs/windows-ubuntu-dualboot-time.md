# Windows + Ubuntu Dual Boot — Fix Windows Time

คู่มือสั้นสำหรับเครื่อง Dual Boot ที่ Ubuntu แสดงเวลาถูก แต่ Windows แสดงเวลาช้ากว่าเวลาประเทศไทย 7 ชั่วโมง

## 1. เปิด Command Prompt แบบ Administrator

1. กด `Win + R`
2. พิมพ์ `cmd`
3. กด `Ctrl + Shift + Enter`
4. เมื่อ UAC ถาม ให้กด **Yes**

## 2. ให้ Windows อ่าน Hardware Clock (RTC) เป็น UTC

รันคำสั่ง:

```bat
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" /v RealTimeIsUniversal /t REG_DWORD /d 1 /f
```

ถ้าสำเร็จจะเห็น:

```text
The operation completed successfully.
```

## 3. เปิด Windows Time Service

```bat
net start w32time
```

ถ้า Service ทำงานอยู่แล้ว Windows จะแจ้งสถานะตามจริง ไม่ต้องแก้ซ้ำ

## 4. Sync เวลา

```bat
w32tm /resync
```

ตรวจว่าเวลาบน Windows กลับมาตรงกับเวลาปัจจุบัน

## หมายเหตุ

- แนวทางนี้ใช้กรณี Dual Boot ที่ Ubuntu/Linux ใช้ RTC แบบ UTC และต้องการให้ Windows ใช้หลักเดียวกัน
- ไม่ต้องเปลี่ยน Ubuntu ให้ใช้ RTC แบบ Local Time
- คำสั่งแก้ Registry ต้องใช้สิทธิ์ Administrator
- หาก `w32tm /resync` แจ้งว่า Windows Time service ยังไม่เริ่ม ให้รัน `net start w32time` ก่อน แล้วจึงสั่ง `w32tm /resync` อีกครั้ง

---

บันทึกจากการทดสอบจริงบน Windows 11 + Ubuntu Dual Boot ก่อนเริ่มพัฒนา PG-BOT
