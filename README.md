# Stok Yönetim Sistemi (ders_project)

Bu proje Flutter ile yazılmış basit ve yerel bir stok yönetim uygulamasıdır. Proje, ürün, lokasyon ve stok işlemlerinin yanı sıra kullanıcı yönetimi (kayıt/giriş/rola göre yönlendirme) için temel yerel (SQLite) altyapısını içerir.

Bu repo üzerinde sayfaları (Ekranlar) teker teker geliştirecek ve ekleyeceksiniz — şu anda oturum (login/register), profil, admin/user ana ekranları ve temel veritabanı altyapısı hazırdır.

Özet
- Yerel SQLite veritabanı (sqflite)
- Şifreler salt + SHA256 ile saklanır
- Oturum bilgisinin kalıcılığı: shared_preferences
- Varsayılan seed admin kullanıcısı uygulama başında oluşturulur

Özellikler
- Kayıt olma (kayıt olanlar otomatik olarak `user` rolü alır)
- Giriş yapma ve role göre yönlendirme (admin -> AdminPanel, user -> UserPanel)
- Profil görüntüleme ve düzenleme (kullanıcı adı güncelleme)
- Şifre değiştirme
- Basit ürün/lokasyon/inventory altyapısı (ileri geliştirmeye açık)

Gereksinimler
- Flutter SDK (en az 3.x, projenizin `pubspec.yaml` içindeki sdk constraint'ine uyun)
- Android/iOS emülatörü veya gerçek cihaz

Kurulum (ilk sefer)

1. Repoyu klonlayın veya workspace'e zaten sahipseniz proje dizinine gidin:

```bash
cd /Users/elif/AndroidStudioProjects/flutterproject/flutterProject
```

2. Paketleri yükleyin:

```bash
flutter pub get
```

Çalıştırma

Emülatörde veya bağlı cihazda uygulamayı başlatın:

```bash
flutter run
```

Statik analiz ve lint kontrolü:

```bash
flutter analyze
```

Varsayılan Admin Hesabı

Uygulama ilk başlatıldığında (main.dart içinde) otomatik olarak aşağıdaki admin hesabı seed edilir (eğer zaten yoksa):

- Kullanıcı adı: `admin`
- Parola: `admin123`

Bu bilgileri kullanarak uygulamaya giriş yapıp Admin Panel’e erişebilirsiniz. (Geliştirme aşamasında bu sabit kimlik bilgileri uygundur; üretimde kesinlikle değiştirilmelidir.)

Kullanıcı Akışı ve Oturum
- Kayıt: Her yeni kayıtlı kullanıcı `user` rolü alır. Kaydolduktan sonra otomatik olarak oturum açılmış olur.
- Giriş: Varolan kullanıcılar kullanıcı adı + parola ile giriş yapar. Giriş başarılıysa rolüne göre ilgili ana ekrana yönlendirilir.
- Profil: Oturum açmış kullanıcının profilini görüntüleyebilir, kullanıcı adını güncelleyebilir ve parolasını değiştirebilir.

Geliştirme: Yeni sayfa/ekran ekleme rehberi

Aşağıdaki adımlar tipik bir yeni ekran (sayfa) eklemek için uygundur:

1. `lib/screens/` altında yeni bir dosya oluşturun, örn `lib/screens/my_new_screen.dart`.
2. Dosyada bir `StatelessWidget` veya `StatefulWidget` tanımlayın.
3. Projede kullanmak için ilgili yere import edin, örn `import 'package:ders_project/screens/my_new_screen.dart';`.
4. Yönlendirme için `Navigator.push(...)` veya `pushReplacement` kullanın.

Örnek hızlı iskelet (dosya):

```dart
import 'package:flutter/material.dart';

class MyNewScreen extends StatelessWidget {
  const MyNewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Sayfa')),
      body: const Center(child: Text('Buraya içerik ekleyin')),
    );
  }
}
```

Veritabanı ve modeller
- Veritabanı erişimi `lib/db/database_helper.dart` içinde.
- Kullanıcı modeli `lib/models/user.dart`.
- Ürün, lokasyon ve inventory ile ilgili modeller `lib/models/` altında bulunur.

Oturum kalıcılığı
- Oturum (giriş yapan kullanıcı) `shared_preferences` ile saklanır; `lib/services/auth_service.dart` içinde yönetilir.
- `AuthService` kullanarak uygulama genelinde aktif kullanıcıya erişebilir ve değişiklikleri dinleyebilirsiniz.

Testler
- Bu proje temel bir Flutter uygulamasıdır; widget/unit testleri `test/` dizinine eklenebilir.
- Hızlı test komutları:

```bash
flutter test
```

Geliştirme ipuçları
- Yeni özelliğe başlamadan önce `flutter analyze` ve `flutter format .` çalıştırın.
- Veritabanında schema değişiklikleri yaparken migration stratejisi ekleyin (şu an basit `CREATE IF NOT EXISTS` mantığı kullanılıyor).

Gelecek geliştirmeler (öneriler)
- Gerçek dünya için parola hashleme algoritmasını güçlendirin (argon2/pbkdf2 gibi) veya sunucu tabanlı auth ekleyin.
- Admin-only sayfaları için route guard (yetki kontrolü) ekleyin.
- UI/UX iyileştirmeleri: tema, renk paleti, responsive düzen.

Katkıda bulunma
- Fork -> branch -> pull request iş akışını kullanın.
- Kod standartlarına uyun ve küçük, odaklı PR'lar açın.

Lisans
- Bu repo örnek amaçlıdır; dilediğiniz lisansı ekleyebilirsiniz (örn MIT).

İhtiyacınız olursa ben sayfaları tek tek oluşturmaya ve README'ye örnek ekran listesini eklemeye yardımcı olurum.
