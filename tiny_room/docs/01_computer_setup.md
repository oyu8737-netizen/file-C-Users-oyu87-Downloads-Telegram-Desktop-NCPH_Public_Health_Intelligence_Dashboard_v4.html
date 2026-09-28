# Хичээл 1. Компьютерээ бэлдэх

> 🎯 **Зорилго:** Апп бүтээх бүх хэрэгслийг Windows компьютерт суулгах
> ⏱ **Хугацаа:** 1–2 цаг (ихэнх нь татах хугацаа)
> 🔁 **Хэдэн удаа:** Зөвхөн нэг удаа

[← Хичээлийн жагсаалт](README.md)

---

## Эхлээд ойлгох 7 үг

| Үг | Энгийнээр | Эрүүл мэндийн зүйрлэл |
|---|---|---|
| **Код** | Компьютерт өгөх алхам алхмаар заавар | Эмчилгээний протокол |
| **Dart** | Кодоо бичиж буй хэл | Протоколын хэл |
| **Flutter** | Dart кодыг iPhone, Android апп болгох хэрэгсэл | Протоколыг бодит үйлдэл болгох баг |
| **SDK** | Flutter-ийн бүх хэрэгслийн багц | Лабораторийн тоног төхөөрөмж |
| **Emulator** | Компьютер доторх хийсвэр утас | Сургалтын манекен |
| **Git / GitHub** | Кодын хувилбарууд / онлайн архив | Өгөгдлийн архив |
| **PowerShell** | Текстээр тушаал өгөх хар цонх | Төхөөрөмжид шууд команд өгөх |

---

## Алхам 1.1 — Git + Flutter-ийг нэг скриптээр суулгах

**Хаана:** ⊞ → `powershell` → Enter → хар цонх нээгдэнэ.

Доорх хайрцгийг **бүхэлд нь** хуулаад PowerShell дээр **хулганы баруун товч** → **Enter**:

```powershell
& {
  $ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'
  Write-Host "=== 1/3: Git ===" -ForegroundColor Cyan
  if (-not (Get-Command git -ErrorAction SilentlyContinue) -and -not (Test-Path 'C:\Program Files\Git\cmd\git.exe')) {
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
  } else { Write-Host "Git байна ✓" }
  $env:Path += ';C:\Program Files\Git\cmd'
  Write-Host "=== 2/3: Flutter татаж, C:\flutter руу задлах (10-40 мин) ===" -ForegroundColor Cyan
  if (Test-Path 'C:\flutter\bin\flutter.bat') { $bin = 'C:\flutter\bin'; Write-Host "Flutter байна ✓" }
  else {
    $rel = Invoke-RestMethod 'https://storage.googleapis.com/flutter_infra_release/releases/releases_windows.json'
    $r = $rel.releases | Where-Object { $_.hash -eq $rel.current_release.stable } | Select-Object -First 1
    Invoke-WebRequest "$($rel.base_url)/$($r.archive)" -OutFile "$env:TEMP\flutter.zip"
    tar -xf "$env:TEMP\flutter.zip" -C 'C:\'; Remove-Item "$env:TEMP\flutter.zip"; $bin = 'C:\flutter\bin'
  }
  Write-Host "=== 3/3: PATH ===" -ForegroundColor Cyan
  $p = [Environment]::GetEnvironmentVariable('Path', 'User'); if (-not $p) { $p = '' }
  if (($p -split ';') -notcontains $bin) { [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';') + ';' + $bin).TrimStart(';'), 'User') }
  Write-Host "`n🎉 БОЛЛОО! PowerShell-ээ хаагаад шинээр нээнэ үү." -ForegroundColor Green
}
```

| Юу хийдэг | Яагаад |
|---|---|
| Git суулгана | Flutter дотроо Git ашигладаг, мөн кодоо GitHub-аас татна |
| Flutter татаж `C:\flutter` руу задална | Богино, зайгүй, латин замд Flutter алдаа гаргадаггүй |
| **PATH**-д нэмнэ | Windows `flutter` тушаалыг хаанаас хайхаа мэддэг болно |

> ⚠️ Дуустал цонхыг **хаахгүй**, **Ctrl+C дарахгүй**. "Yes" асуувал **Yes** дарна.

---

## Алхам 1.2 — VS Code (код засах программ)

1. https://code.visualstudio.com → **Download for Windows** → суулгана.
2. Нээгээд `Ctrl + Shift + X` → `Flutter` гэж хайж → **Install**.

**Яагаад:** Кодыг өнгөөр ялгаж, алдааг улаанаар зурж харуулдаг.

---

## Алхам 1.3 — Android Studio (Android хэрэгсэл + хийсвэр утас)

1. https://developer.android.com/studio → татна.
2. Татсан `.exe` дээр **баруун товч → Run as administrator** → **Yes**.
   > "could not request administrative privileges" гэж гарвал → [Хичээл 7](07_troubleshooting.md#android-studio-админ-эрх)
3. Анх нээхэд: **Do not import** → **Standard** → лиценз бүрийг **Accept** → **Finish**.
4. **More Actions → SDK Manager → SDK Tools** таб → ✅ **Android SDK Command-line Tools (latest)** → **Apply**.

**Яагаад:** Бид кодоо VS Code-оор бичнэ. Android Studio-г зөвхөн Android SDK болон хийсвэр утас авахын тулд суулгаж байна.

> 🍎 iPhone-д жинхэнэ апп бүтээхэд **Mac** заавал хэрэгтэй. Windows дээр Android + вэбээр хөгжүүлнэ.

---

## ✅ Шалгах

**Шинэ** PowerShell нээгээд:

```powershell
flutter doctor
```

| Мөр | Байх ёстой |
|---|---|
| Flutter | `[√]` |
| Android toolchain | `[√]` (эсвэл `[!]` — лиценз, cmdline-tools) |
| Chrome | `[√]` |
| Visual Studio | `[X]` байж болно — **хамаагүй** (Windows программд л хэрэгтэй) |

---

➡️ **Дараагийн хичээл:** [2. Аппаа ажиллуулах](02_run_app.md)
