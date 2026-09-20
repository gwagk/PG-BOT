# PG-BOT — PORT GUARD BOT

PG-BOT เป็น Windows Batch utility ขนาดเล็ก พัฒนาขึ้นเพื่อช่วยลดงานซ้ำในการทำความสะอาดไฟล์ชั่วคราวของผู้ใช้ โดยยึดหลัก Functional Minimalism: ทำเฉพาะหน้าที่ที่จำเป็น ตรวจสอบผล และไม่รบกวนงานหลักของผู้ใช้

## แนวคิดหลัก

- User First — บอทต้องไม่แย่งงานหรือขัดจังหวะผู้ใช้
- Minimal Scope — ทำเฉพาะ User TEMP
- No Admin — ไม่ยกระดับสิทธิ์
- No Guess — ไม่แตะพื้นที่ที่ไม่ได้กำหนดไว้
- No Background Agent — ไม่ติดตั้ง service หรือโปรแกรมค้างเบื้องหลัง
- No Personal Files — ไม่แตะ Documents, Desktop, Downloads หรือข้อมูลส่วนบุคคล
- Verify — วัดพื้นที่ก่อนและหลังทำงาน
- One Receipt — เก็บผลล่าสุดเพียงไฟล์เดียว `PG-BOT-LAST.txt` และเขียนทับในรอบถัดไป
- Clean without creating clutter — ตัวเก็บขยะต้องไม่สร้างขยะของตัวเอง

## ขอบเขตของ Core ที่ทดสอบ

1. อ่านขนาดไฟล์ใน `%TEMP%` ของผู้ใช้
2. ลบรายการภายใน User TEMP ด้วย PowerShell `Remove-Item`
3. รายการที่ลบไม่ได้/กำลังถูกใช้งานจะถูกข้ามด้วย ErrorAction SilentlyContinue
4. Scan ซ้ำหลังการทำความสะอาด
5. คำนวณพื้นที่ที่ลดลงจาก Before - After
6. เขียนผลล่าสุดลง `PG-BOT-LAST.txt`

`Remove-Item` ในกระบวนการนี้ลบรายการโดยตรง ไม่ได้ย้ายรายการไป Recycle Bin

## สิ่งที่ PG-BOT ไม่ทำ

PG-BOT Core ไม่ปิด Windows Update, ไม่แก้ Defender/Firewall, ไม่ลบ Event Log, ไม่ถอนโปรแกรม, ไม่เปลี่ยนรหัสผ่าน, ไม่เก็บข้อมูลส่วนบุคคล, ไม่ส่งข้อมูลออกจากเครื่อง และไม่ใช้สิทธิ์ Administrator

## พัฒนาการและการทดสอบ

การพัฒนาใช้แนวทาง Scan → Clean → Verify → Receipt โดยทดสอบคำสั่งทีละส่วนก่อนประกอบเป็น Batch file

ระหว่างทดสอบพบปัญหาการต่อบรรทัด PowerShell ด้วย caret (`^`) ทำให้ CMD แยก `Remove-Item` ออกจาก PowerShell และเกิดข้อความว่าไม่รู้จักคำสั่ง จึงแก้เป็น PowerShell command บรรทัดเดียวและทดสอบซ้ำจนกระบวนการ Clean/Verify/Receipt ทำงานได้

ผลทดสอบล่าสุดของ Core แสดงค่า Cleaned และ Remain หลัง Verify และจบด้วยสถานะ DONE

## สถานะปัจจุบัน

ไฟล์ใน repository นี้เป็น Core ที่ผ่านการทดสอบแบบ manual แล้ว แต่ยังคง `pause` ไว้สำหรับการตรวจสอบผลก่อนปิดหน้าต่าง จึงควรถือเป็น tested development snapshot จนกว่าจะปิดงาน Production/Auto mode

## แนวทาง Production

Production มีเป้าหมายให้ผู้ใช้เปิดเพียงครั้งเดียว แล้ว PG-BOT ทำงานและจบเอง ส่วน Auto mode จะใช้ Windows Task Scheduler โดยออกแบบตามหลัก “Never interrupt the user” — ทำงานเมื่อเหมาะสมและไม่แย่งทรัพยากร/หน้าจอจากงานเร่งด่วนของผู้ใช้

## งานบำรุงรักษา Windows อื่น

PG-BOT ไม่ควรถูกขยายให้ทำทุกอย่างแทนผู้ใช้ โดยเฉพาะ Windows Update และงานที่มีผลต่อระบบ ควรแยกเป็นคำแนะนำ/Checklist ตามนโยบายของหน่วยงาน เพื่อให้ Core เล็ก ตรวจสอบง่าย และไม่ขัดกับการตั้งค่าหรือการบริหารเครื่องขององค์กร.
