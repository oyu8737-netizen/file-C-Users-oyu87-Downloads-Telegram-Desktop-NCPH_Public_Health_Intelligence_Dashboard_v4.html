# Хичээл 4. Firebase: account, найзууд, статистик

> 🎯 **Зорилго:** Account, аль ч төхөөрөмж дээр өрөө сэргээх, найзууд, бүртгэл харах
> ⏱ **Хугацаа:** 45 минут
> 📋 **Өмнөх нөхцөл:** [Хичээл 2](02_run_app.md) · Google бүртгэл
> 🔥 **Таны төсөл:** `tiny-room-e0434` (аль хэдийн үүссэн ✅)

[← Хичээлийн жагсаалт](README.md)

**Firebase гэж юу вэ?** Google-ийн үнэгүй "сервер". Account, мэдээллийн сан, статистикийг сервер бичихгүйгээр ашиглана. Жижиг аппад **үнэгүй**.

| Алхам | Хаана | Хугацаа |
|---|---|---|
| 4.1 Төсөл | 🌐 Chrome | ✅ хийгдсэн |
| 4.2 Email/Password | 🌐 Chrome | 2 мин |
| 4.3 Firestore + дүрэм | 🌐 Chrome | 5 мин |
| 4.4 Хэрэгсэл суулгах | 💻 PowerShell | 10 мин |
| 4.5 Аппыг холбох | 💻 PowerShell | 5 мин |
| 4.6 Өөрийгөө admin болгох | 🌐 Chrome | 3 мин |

---

## 4.2 — Email/Password асаах 🌐

👉 **https://console.firebase.google.com/project/tiny-room-e0434/authentication/providers**

1. **Get started** (анх удаа бол)
2. **Email/Password** дээр дарна
3. **Эхний** Enable-ийг асаана (хоёр дахь "Email link"-ийг **хөндөхгүй**) → **Save**

✅ Жагсаалтад `Email/Password — Enabled`

> **Яагаад:** Хэрэглэгч имэйл, нууц үгээр бүртгүүлнэ. Нууц үгийг Google аюулгүй хадгалдаг, бид хадгалахгүй.

---

## 4.3 — Мэдээллийн сан (Firestore) + хамгаалалтын дүрэм 🌐

👉 **https://console.firebase.google.com/project/tiny-room-e0434/firestore**

1. **Create database**
2. Location: **`asia-east2 (Hong Kong)`** → *Дараа нь өөрчлөх боломжгүй*
3. **Start in production mode** → **Create**
4. Дээд талын **Rules** таб
5. Байгаа бичгийг **бүгдийг устгаад** → [`firestore.rules`](../firestore.rules) файлын **бүх агуулгыг** хуулж тавина → **Publish**

> 🔄 **Кодыг шинэчлэх бүрд** энэ дүрэм өөрчлөгдсөн байж магадгүй. v0.3-т `registrations` нэмэгдсэн тул **дахин Publish** хийгээрэй.

**Дүрэм юу хамгаалдаг вэ:**

| Өгөгдөл | Хэн харах | Хэн өөрчлөх |
|---|---|---|
| Таны өрөө, алхам | Та + **найзууд** + admin | Зөвхөн та |
| Найзын код | Нэвтэрсэн хүн (код хайхад) | Зөвхөн эзэн нь (нэг удаа) |
| Бүртгэлийн жагсаалт | **Зөвхөн admin** | Хүн бүр өөрийн мөрийг |

---

## 4.4 — Хэрэгслүүд суулгах (нэг удаа) 💻

```powershell
& {
  Write-Host "=== 1/3: Node.js ===" -ForegroundColor Cyan
  if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
    $env:Path += ";C:\Program Files\nodejs"
  } else { Write-Host "Node.js байна ✓" }
  Write-Host "=== 2/3: Firebase CLI ===" -ForegroundColor Cyan
  npm install -g firebase-tools
  Write-Host "=== 3/3: FlutterFire CLI ===" -ForegroundColor Cyan
  dart pub global activate flutterfire_cli
  $pubBin = "$env:LOCALAPPDATA\Pub\Cache\bin"
  $p = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (($p -split ';') -notcontains $pubBin) { [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';') + ';' + $pubBin), 'User') }
  Write-Host "`n🎉 БОЛЛОО! PowerShell-ээ хаагаад шинээр нээнэ үү." -ForegroundColor Green
}
```

| Хэрэгсэл | Яагаад |
|---|---|
| Node.js | Firebase CLI нь Node.js дээр ажилладаг |
| Firebase CLI | Компьютерээс Firebase руу нэвтрэх |
| FlutterFire CLI | Firebase-ийн тохиргоог кодод автоматаар бичих |

> "running scripts is disabled" гэвэл: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` → `Y` → дахин ажиллуулна.

---

## 4.5 — Аппыг Firebase-тэй холбох 💻

**Шинэ** PowerShell дээр мөр бүрийг **тус тусад нь**:

```powershell
firebase login
```
> Chrome нээгдэнэ → Google бүртгэлээ сонгоно → **Allow**.

```powershell
cd $HOME\tiny-room-repo\tiny_room; flutterfire configure --project=tiny-room-e0434 --platforms=android,ios,web
```
> Асуулт гарвал **Enter**. ✅ `lib/firebase_options.dart generated successfully`

```powershell
flutter run -d chrome
```
> Одоо **нэвтрэх дэлгэц** гарна → **Бүртгүүлэх** → нэр, имэйл, нууц үг.
> **Найзууд** таб → таны **6 үсэгтэй найзын код** 🎉

### ☁️ Өөр төхөөрөмж дээр шалгах

1. Утас эсвэл өөр компьютер дээр аппыг нээнэ.
2. **Нэвтрэх** → ижил имэйл, нууц үг.
3. **"☁️ Өмнөх өрөө, coin тань сэргээгдлээ!"** гэж гарч, өрөө тань буцаж ирнэ.

> Тэр төхөөрөмж дээр нэвтрэхээс өмнө алхсан алхам байвал **нэмэгдэнэ**, давхар coin өгөхгүй.

---

## 4.6 — Өөрийгөө admin болгох 🌐

1. 👉 **https://console.firebase.google.com/project/tiny-room-e0434/authentication/users**
2. Таны имэйлийн мөрөнд байгаа **User UID**-ийн хажууд **📋** дарж хуулна.
3. 👉 **https://console.firebase.google.com/project/tiny-room-e0434/firestore/data**
4. **+ Start collection** → ID: `admins` → **Next**
5. **Document ID**: хуулсан UID → Field `role` · string · `admin` → **Save**
6. Апп дээр `R` → **Би** → **📈 Хэрэглэгчийн статистик** гарна.

> **Яагаад гараар?** Апп дотроос өөрчилж болдог бол хэн ч өөрийгөө admin болгоно.

---

## 📈 Бүртгэлийг хаанаас харах вэ

| Хаана | Юу харагдах |
|---|---|
| **Апп → Би → Хэрэглэгчийн статистик** | Нийт/өнөөдөр идэвхтэй/шинэ хэрэглэгч, 7 хоногийн график, **сүүлийн бүртгэлүүд** (нэр, имэйл, огноо, 📱/🌐) |
| [**Authentication → Users**](https://console.firebase.google.com/project/tiny-room-e0434/authentication/users) | Бүх account: имэйл, бүртгүүлсэн огноо, сүүлд нэвтэрсэн огноо |
| [**Firestore → registrations**](https://console.firebase.google.com/project/tiny-room-e0434/firestore/data/~2Fregistrations) | Хүснэгт: нэр, имэйл, `createdAt`, `platform` (android/iOS/web), `lastLoginDay` |
| [**Analytics → Dashboard**](https://console.firebase.google.com/project/tiny-room-e0434/analytics) | Өдөр бүрийн идэвхтэй хэрэглэгч, улс, төхөөрөмж (24 цаг хоцорно) |

---

## ✅ Шалгах

- [ ] Бүртгүүлж, найзын код харагдсан
- [ ] Өөр төхөөрөмж дээр нэвтрэхэд өрөө сэргэсэн
- [ ] Firebase → Authentication → Users дээр өөрийн имэйлээ харсан
- [ ] Апп дээр Хэрэглэгчийн статистик нээгдсэн

➡️ **Дараагийн хичээл:** [5. Утсан дээр жинхэнэ алхам](05_phone_steps.md)
