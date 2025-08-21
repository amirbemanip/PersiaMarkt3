import os

# مسیر پروژه (محلی که اسکریپت داخلشه)
project_dir = os.getcwd()

# مسیر پوشه lib
lib_dir = os.path.join(project_dir, "lib")

# فایل خروجی
output_file = "all_flutter_lib_code.txt"

with open(output_file, "w", encoding="utf-8") as outfile:
    if not os.path.exists(lib_dir):
        print(f"⛔️ پوشه lib پیدا نشد: {lib_dir}")
    else:
        print(f"🔎 در حال پردازش پوشه: {lib_dir}")
        for root, dirs, files in os.walk(lib_dir):
            for file in files:
                file_path = os.path.join(root, file)
                # نوشتن اسم فایل و مسیر قبل از کد
                outfile.write(
                    f"\n\n====================\n"
                    f"فایل: {file}\n"
                    f"مسیر: {file_path}\n"
                    f"====================\n\n"
                )
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        outfile.write(f.read())
                except Exception as e:
                    outfile.write(f"// خطا در خواندن فایل: {e}\n")

print(f"✅ همه‌ی فایل‌های داخل lib/ استخراج و در {output_file} ذخیره شد.")
