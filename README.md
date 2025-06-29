# Dietitian - AI栄養管理アプリ

**Dietitian** は、AI を活用した栄養管理アプリケーションです。  
料理の画像を解析し、栄養情報を自動で抽出。  
さらに、登録された個人の身体情報（身長・体重・年齢・性別など）に基づいて、パーソナライズされた健康アドバイスを提供します。

---

## 特徴

- 📷 **画像解析による食事記録**  
  スマートフォンで撮影した料理写真をアップロードするだけで、栄養素（カロリー・たんぱく質・脂質・炭水化物など）を自動で分析。

- 🧠 **AIによる栄養アドバイス**  
  あなたの身体情報や過去の食事履歴に応じて、健康維持・改善に向けたアドバイスを提示。

- 📊 **グラフと履歴で振り返り**  
  食事の栄養バランスやカロリーの推移をグラフ表示。毎日の食生活をビジュアルでチェックできます。

- 🔐 **Google認証対応**  
  Firebase を用いたログイン機能で、セキュアなユーザーデータ管理が可能。

---

## セットアップ方法

### 前提条件

- Flutter 3.x インストール済み
- Firebase プロジェクト作成済み
- Android Studio または Xcode インストール済み（実機またはエミュレーター用）

### 手順

1. このリポジトリをクローン

```bash
git clone https://github.com/yourusername/dietitian.git
cd dietitian
```

2. 依存パッケージを取得

```bash
flutter pub get
```

3. Firebase CLI を用いて初期化（必要に応じて）

```bash
flutterfire configure
```

4. lib/firebase_options.dart を自動生成するか、既存ファイルを配置

5. SHA-1を取得し、設定する(googleアカウントのOAuth用)

android/key.propertiesを作成する
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=your_keystore_file.jks
```

6. SHA-1を取得する

```bash
keytool -list -v -keystore your_keystore_file.jks -alias your_key_alias -storepass your_store_password
```

7. Firebase ConsoleでAndroidアプリのSHA-1を設定

8. google-services.jsonを `android/app/` ディレクトリに配置または上書き

9. 実機またはエミュレーターで起動
```bash
flutter run
```

### ディレクトリ構成（抜粋）
```bash
lib/
├── pages/              # 各画面（ホーム、記録、情報など）
├── resources/          # 画像、フォント、ローカライズファイル
├── services/           # API呼び出し、Firebase連携など
├── utils/              # ユーティリティ関数
├── widget/             # 共通ウィジェット
└── main.dart           # エントリーポイント
```

### 開発技術
* Flutter（iOS / Android 対応）

* Firebase Authentication / Firestore / Storage

* Google Cloud Functions

* Python + FastAPI（画像解析 API）

### ライセンス
MIT License
