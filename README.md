# tenangin-mobile

Aplikasi Tenangin User, pengguna anonymous untuk konsultasi yang terjaga dan secure.

## Quick Start

1. **Supabase Setup**
    - Create account & project at [https://supabase.com](https://supabase.com).
    - Copy project URL and anon/public API key.
    - Match your Auth, Database, Storage setup/rules to the web.
    - (Optional) Run/init your SQL schema in Supabase > SQL Editor.
    - In the mobile repo, update your environment or config file with:
      ```
      SUPABASE_URL=your-project-url
      SUPABASE_ANON_KEY=your-anon-key
      # ...other Supabase settings as needed
      ```

2. **Clone**
    ```bash
    git clone https://github.com/faizakmalz/tenangin-mobile.git
    cd tenangin-mobile
    ```

3. **Install Dependencies**
    pake VS Code/Android Studio (Dont forget FlutterSDK and AndroidSDK)
    ```bash
    flutter pub get
    ```

4. **Setup Environment**
    - Copy sample env/config to local:
      ```bash
      cp .env.example .env
      ```
    - Edit `.env` with Supabase keys and endpoints.

5. **Run App**
    ```bash
    flutter run
    # (or: run debugging (vscode))
    ```

---
