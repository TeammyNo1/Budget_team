# 🏖️ Beach Budget — แอปรายรับ-รายจ่ายส่วนตัว

Flutter + Firebase (Auth / Firestore / Storage) ธีมทรายครีม–ฟ้าน้ำทะเล
ออกแบบให้ใช้คนเดียว ข้อมูลผูกกับบัญชี Google ของคุณเอง

---

## ✨ มีอะไรบ้าง

| หน้า | ทำอะไรได้ |
|---|---|
| **ภาพรวม** | ยอดคงเหลือ / รายรับ / รายจ่าย สลับดูเป็น **วัน · สัปดาห์ · เดือน · ปี** ได้, โดนัทสัดส่วนหมวดหมู่, กราฟแท่งรายวัน, การ์ดเตือน (ค่ากินใช้ไปเท่าไหร่, ใช้ได้อีกวันละเท่าไหร่, หนี้คงเหลือ) |
| **รายการ** | รายการทั้งหมดจัดกลุ่มตามวัน ค้นหา + กรองตามหมวด/ประเภท แตะเพื่อดูรายละเอียด แก้ไข ลบ |
| **แผน** | สูตรแบ่งรายจ่าย: เงินเดือน → หัก ปกส. → รายได้สุทธิ → แผนจ่าย → เหลือเก็บ พร้อมแถบเทียบ **แผน vs จ่ายจริง** ทุกก้อน และเส้นบอกว่า "ควรใช้ไปเท่าไหร่แล้ว" ตามวันที่ผ่านไปของเดือน |
| **หนี้** | ก้อนหนี้แต่ละคน (พี่ / เพื่อน / เพื่อนอีกคน) ติดตาม **ยอดคงเหลือ** — บันทึกรายการหมวด "จ่ายหนี้" แล้วยอดหนี้จะลดให้อัตโนมัติ ลบรายการก็คืนยอดกลับให้ |
| **ตั้งค่า** | แก้เงินเดือน, ประกันสังคม, ค่ากินต่อวัน (แยกวันทำงาน/วันหยุด), เพิ่ม-ลบรายการในสูตร, ออกจากระบบ |

**การกรอกข้อมูล** = กรอกมือ (จำนวนเงินตัวใหญ่ + ปุ่มลัด +50 / +100 / +150…, ชิปหมวดหมู่, ปุ่มลัดวันนี้/เมื่อวาน) **และแนบรูปสลิปได้** จากกล้องหรือคลังภาพ รูปเก็บใน Firebase Storage แตะดูขยายได้ในหน้ารายละเอียด

---

## 🚀 ติดตั้ง (ทำครั้งเดียว)

### 1. เตรียมเครื่อง

```bash
flutter --version     # ต้องมี Flutter 3.24+ (Dart 3.5+)
```

### 2. สร้างโปรเจกต์ Firebase

1. ไปที่ https://console.firebase.google.com → **Add project**
2. เข้า **Authentication → Sign-in method → Google** → เปิดใช้งาน
3. เข้า **Firestore Database → Create database** → เลือก *Production mode* → รีเจียน `asia-southeast1`
4. เข้า **Storage → Get started** → รีเจียนเดียวกัน

### 3. สร้างโฟลเดอร์แพลตฟอร์ม (สำคัญ — โปรเจกต์นี้มีแต่โค้ด `lib/`)

```bash
cd beach_budget
flutter create --org com.yourname --platforms=android,ios .
```

คำสั่งนี้จะสร้าง `android/` และ `ios/` ให้ โดย **ไม่แตะไฟล์ใน `lib/`** ที่มีอยู่แล้ว

### 4. ผูกโปรเจกต์เข้ากับแอป

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

คำสั่งนี้จะ **เขียนทับ `lib/firebase_options.dart`** ด้วยคีย์จริง และวาง
`android/app/google-services.json` + `ios/Runner/GoogleService-Info.plist` ให้เอง
(ไฟล์ `firebase_options.dart` ที่แถมมาเป็นแค่แบบร่างให้เห็นโครง)

### 5. ⚠️ ใส่ SHA-1 (จำเป็นมากสำหรับ Google Login บน Android)

ถ้าไม่ทำขั้นนี้ กดปุ่มล็อกอินแล้วจะเด้งกลับเฉย ๆ ไม่มี error

```bash
cd android
./gradlew signingReport      # Windows ใช้ gradlew.bat signingReport
```

คัดลอกค่า **SHA1** ของ variant `debug` → ไปที่
Firebase Console → ⚙️ Project settings → เลือกแอป Android → **Add fingerprint**
แล้วดาวน์โหลด `google-services.json` ใหม่มาทับของเดิม

> ตอนจะปล่อยเป็น release ต้องเพิ่ม SHA-1 ของ release keystore เข้าไปด้วยอีกอัน

### 6. ติดตั้งแพ็กเกจแล้วรัน

```bash
flutter pub get
flutter run
```

### 7. อัปโหลด security rules

```bash
firebase deploy --only firestore:rules,storage
```
หรือก๊อปเนื้อหาใน `firestore.rules` / `storage.rules` ไปวางในหน้า Rules ของ Console

---

## 🍎 เพิ่มเติมสำหรับ iOS

**`ios/Runner/Info.plist`** — เพิ่มก่อน `</dict>` ปิดท้าย:

```xml
<key>NSCameraUsageDescription</key>
<string>ใช้กล้องเพื่อถ่ายรูปสลิปแนบกับรายการ</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ใช้คลังภาพเพื่อเลือกรูปสลิปแนบกับรายการ</string>

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- ค่า REVERSED_CLIENT_ID จาก GoogleService-Info.plist -->
      <string>com.googleusercontent.apps.xxxxxxxx-yyyyyyyy</string>
    </array>
  </dict>
</array>
```

**`ios/Podfile`** — ตั้ง platform ขั้นต่ำเป็น 13:
```ruby
platform :ios, '13.0'
```

## 🤖 เพิ่มเติมสำหรับ Android

**`android/app/build.gradle`** — `minSdkVersion` ต้อง **23** ขึ้นไป:

```gradle
defaultConfig {
    minSdkVersion 23
    multiDexEnabled true
}
```

---

## 🗄️ โครงสร้างข้อมูลใน Firestore

```
users/{uid}/
├── settings/main              ← เงินเดือน, ปกส., ค่ากิน/วัน, สูตรแบ่งรายจ่าย
├── transactions/{autoId}      ← type, amount, categoryId, date, note, slipUrl, debtId
└── debts/{autoId}             ← name, principal, paid, monthlyPlan
```

รูปสลิป: `Storage → slips/{uid}/{timestamp}.jpg`

**ไม่ต้องสร้าง composite index** — ทุก query ใช้ฟิลด์ `date` ฟิลด์เดียว

---

## 📁 โครงสร้างโค้ด

```
lib/
├── main.dart                 จุดเริ่มต้น + สลับหน้า login/หน้าหลักตามสถานะ auth
├── firebase_options.dart     (ถูกเขียนทับโดย flutterfire configure)
├── theme/app_theme.dart      พาเลตต์ชายหาด + ธีม Material 3 ทั้งแอป
├── models/
│   ├── category.dart         หมวดหมู่ฝังในแอป (ค่าหอ ค่าไฟ ค่ากิน จ่ายหนี้ …)
│   ├── transaction.dart      รายการรับ/จ่าย
│   ├── debt.dart             ก้อนหนี้ + ยอดคงเหลือ
│   └── plan.dart             สูตรแบ่งรายจ่าย + ค่าตั้งต้น
├── services/                 auth / firestore / storage
├── providers/app_state.dart  สถานะรวม: ช่วงเวลาที่ดูอยู่ + ยอดสรุป
├── screens/                  login, home_shell, dashboard, transactions,
│                             transaction_detail, add_transaction, plan,
│                             debts, settings
└── widgets/                  wave_header, charts, period_switcher,
                              section_card, tx_tile
```

---

## 🔢 สูตรที่แอปคำนวณให้

```
รายได้สุทธิ   = เงินเดือน − ประกันสังคม − หักอื่น ๆ
งบค่ากิน/เดือน = (จำนวนวันจันทร์-ศุกร์ × เรทวันทำงาน) + (วันเสาร์-อาทิตย์ × เรทวันหยุด)
แผนจ่ายทั้งเดือน = รายจ่ายคงที่ทุกบรรทัด + งบค่ากิน + ยอดตั้งใจจ่ายหนี้
เหลือเก็บ      = รายได้สุทธิ − แผนจ่ายทั้งเดือน
ใช้ได้อีกวันละ  = (แผนจ่ายทั้งเดือน − ที่จ่ายไปแล้ว) ÷ จำนวนวันที่เหลือในเดือน
```

**ค่าตั้งต้นที่ใส่ไว้ให้แล้ว** (แก้ได้ในหน้าตั้งค่า): เงินเดือน 26,000 · ปกส. 875 ·
ค่าหอ 4,000 · ค่าไฟ 1,750 (1,500–2,000) · ค่าน้ำ 100 · ค่าน้ำมัน 300 ·
ซักผ้า 440 · ของใช้ 650 (500–800) · ค่ากิน 150/วันทำงาน 250/วันหยุด ·
หนี้ พี่ 5,200 / เพื่อน 800 / เพื่อนอีกคน 1,500

> ตัวเลขชุดนี้จะถูกใส่ให้อัตโนมัติ **ครั้งแรกที่ล็อกอิน** เท่านั้น หลังจากนั้นแก้ในแอปได้ตามใจ

---

## 💡 อยากต่อยอด

- **อ่านสลิปอัตโนมัติ (OCR)** — เพิ่ม `google_mlkit_text_recognition` แล้วดึงยอดเงินจากรูปที่แนบ (สลิปธนาคารไทยรูปแบบไม่เหมือนกัน ต้องเขียน regex จับเลขหลัง "จำนวนเงิน" เอง)
- **แจ้งเตือนสิ้นเดือน** — `flutter_local_notifications` เตือนวันเงินเดือนออก / เตือนตอนใช้เกินแผน
- **ใช้ออฟไลน์** — `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);` (Android/iOS เปิดอยู่แล้วโดยดีฟอลต์)
- **ส่งออก CSV** — วนอ่าน collection `transactions` แล้วเขียนไฟล์ด้วย `share_plus`
