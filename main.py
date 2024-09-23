"""
Install the Google AI Python SDK

$ pip install google-generativeai
"""

import os
import shutil
import google.generativeai as genai
from google.generativeai.types import HarmCategory, HarmBlockThreshold

genai.configure(api_key="AIzaSyBX1AuvpDZWMC80GWqXzkqpcYb79cVGAFs")

# Create the model
generation_config = {
  "temperature": 1,
  "top_p": 0.95,
  "top_k": 64,
  "max_output_tokens": 8192,
  "response_mime_type": "text/plain",
}

model = genai.GenerativeModel(
  model_name="gemini-1.5-pro-exp-0827",
  generation_config=generation_config,
  safety_settings={
        HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
        HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
        HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_NONE,
        HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE
    }
)

chat_session = model.start_chat(
  history=[
    {
      "role": "user",
      "parts": [
        "Chức năng chính của bạn là dịch các văn bản dài, bài viết hoặc tài liệu sang tiếng Việt. Bạn có hơn 10 năm kinh nghiệm trong lĩnh vực dịch thuật và thành thạo trong việc chuyển tải nội dung từ ngôn ngữ gốc sang tiếng Việt một cách chính xác và tự nhiên. Bản dịch của bạn cần trung thành với nội dung gốc, đồng thời đảm bảo sự lưu loát và dễ hiểu cho người đọc tiếng Việt. Khi dịch, hãy tuân theo các nguyên tắc sau: \n1. Duy trì giọng điệu và phong cách của văn bản gốc. \n2. Chuyển tải chính xác ý nghĩa và ngữ cảnh của nội dung. \n3. Sử dụng thuật ngữ chuyên ngành phù hợp khi cần thiết. \n4. Nếu gặp từ ngữ hoặc khái niệm khó dịch, giữ nguyên từ gốc và cung cấp giải thích ngắn gọn trong ngoặc đơn. \n5. Đối với nội dung phức tạp hoặc đa chủ đề, có thể chia nhỏ bản dịch thành các phần có cấu trúc để dễ theo dõi. \nGiới hạn độ dài: Nếu văn bản gốc quá dài, hãy chia nhỏ bản dịch thành các phần khoảng 1000-1500 từ và đề nghị người dùng xác nhận trước khi tiếp tục phần tiếp theo. \nQUAN TRỌNG: Luôn bắt đầu bằng cách xác nhận ngôn ngữ gốc của văn bản cần dịch và đảm bảo rằng bạn đang dịch sang tiếng Việt.",
      ],
    },
    {
      "role": "model",
      "parts": [
        "Tôi đã hiểu yêu cầu của bạn. \n\nChức năng chính của tôi là dịch các văn bản dài, bài viết hoặc tài liệu sang tiếng Việt. Tôi sẽ cố gắng hết sức để chuyển tải nội dung từ ngôn ngữ gốc sang tiếng Việt một cách chính xác, tự nhiên và dễ hiểu, đồng thời tuân thủ các nguyên tắc bạn đã đề ra.\n\nĐể tôi có thể bắt đầu dịch, vui lòng cung cấp cho tôi văn bản cần dịch và cho biết **ngôn ngữ gốc** của văn bản đó. \n\nVí dụ: \n\n\"Vui lòng dịch văn bản sau sang tiếng Việt. Ngôn ngữ gốc là tiếng Anh.\" \n\nSau khi nhận được thông tin này, tôi sẽ xem xét văn bản và xác nhận lại với bạn trước khi bắt đầu quá trình dịch thuật. Nếu văn bản quá dài, tôi sẽ chia nhỏ thành các phần và đề nghị bạn xác nhận trước khi tiếp tục phần tiếp theo. \n\nTôi sẵn sàng hỗ trợ bạn dịch thuật! \n",
      ],
    },
  ]
)



def upload_and_translate_file(file_path, target_language):
    file_content = genai.upload_file(path=file_path, display_name=os.path.basename(file_path))
    response = chat_session.send_message([file_content, f"Can you translate this document, into {target_language}?"])
    return response.text

def save_to_markdown(filename, content):
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(content)

def translate_all_files_in_folder(source_folder, target_folder, target_language):
    for filename in os.listdir(source_folder):
        if filename.endswith(".md"):
            source_file_path = os.path.join(source_folder, filename)
            translated_content = upload_and_translate_file(source_file_path, target_language)
            
            target_file_path = os.path.join(target_folder, filename)
            save_to_markdown(target_file_path, translated_content)

            # Rename original file in source folder
            base_filename, file_extension = os.path.splitext(filename)
            renamed_filename = f"{base_filename}_translated{file_extension}"
            renamed_file_path = os.path.join(source_folder, renamed_filename)
            shutil.move(source_file_path, renamed_file_path)

translate_all_files_in_folder("./en2", "./vi", "Vietnamese")