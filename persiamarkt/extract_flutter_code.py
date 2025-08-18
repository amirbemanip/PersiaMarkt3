import os

# مسیر پروژه = همان پوشه‌ای که اسکریپت داخلشه
project_dir = os.getcwd()

# فایل خروجی
output_file = "all_flutter_code.txt"

with open(output_file, "w", encoding="utf-8") as outfile:
    for root, dirs, files in os.walk(project_dir):
        for file in files:
            if file.endswith(".dart"):
                file_path = os.path.join(root, file)
                # نوشتن اسم فایل و مسیر قبل از کد
                outfile.write(f"\n\n====================\nفایل: {file}\nمسیر: {file_path}\n====================\n\n")
                try:
                    with open(file_path, "r", encoding="utf-8") as f:
                        outfile.write(f.read())
                except Exception as e:
                    outfile.write(f"// خطا در خواندن فایل: {e}\n")

print(f"تمام کدهای Dart استخراج و در {output_file} ذخیره شد.")
