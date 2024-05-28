# 1. Data set 

Dữ liệu gồm 5 bảng: banhang (Fact) và 4 bảng dim là branch, customer, ty_gia, staff. Ta có thể quan sát qua diagram

<img width="686" alt="Screen Shot 2024-05-28 at 15 55 40" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/1d0e9d74-f332-49b5-bac6-e4f69567abb7">

Dữ liệu này mô tả các thông tin liên quan đến quá trình bán hàng của một doanh nghiệp, bao gồm thông tin chi nhánh, khách hàng, giao dịch bán hàng cụ thể, tỷ giá hối đoái và nhân viên bán hàng. Sơ đồ bao gồm các thực thể chính sau:
1. Branch (Chi nhánh): Chứa thông tin về các chi nhánh kinh doanh như mã chi nhánh, địa chỉ, người quản lý.
2. Customer (Khách hàng): Lưu trữ thông tin về khách hàng như mã khách hàng, tên, email, số điện thoại.
3. Ban_hang (Bán hàng): Chứa dữ liệu về các giao dịch bán hàng cụ thể như mã giao dịch, ngày giao dịch, mã sản phẩm, tên sản phẩm, mã khách hàng, tên khách hàng, mã chi nhánh, số tiền bán được (fcy_amt), và lợi nhuận (lcy_amt).
4. Ty_gia (Tỷ giá): Chứa thông tin về tỷ giá hối đoái theo ngày giao dịch.
5. Staff (Nhân viên): Lưu trữ thông tin về nhân viên bán hàng như mã nhân viên, tên, ngày bắt đầu làm việc và hệ số lương.

# 2. Clean data
Sau khi ta tìm hiểu kỹ về dữ liệu, về cơ bản dữ liệu khá sạch. Tuy nhiên vẫn tồn tại 1 số vấn đề nhỏ. Cụ thể là tổn tại các bảng chứa 1 vài cột mà tất cả các record của các cột đó bị thừa dấu “ (Có thể là ở đầu, có thể là ở cuối). Điều này cũng sẽ có thể ảnh hưởng đến kiểu dữ liệu. Ví dụ:

<img width="648" alt="Screen Shot 2024-05-28 at 15 59 44" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/f34b2786-b92d-40d2-8202-448166a4f999">

Ở bảng “branch”, cột STOREDID bị thừa dấu “ ở đầu mỗi record, cột MANAGER bị thừa dấu “ ở cuối mỗi record.

Ý tưởng: Tạo 1 procedure trong đó truyền các biến là tên bảng và tên cột vào. Câu lệnh sẽ kiểm tra xem có tồn tại dấu “ ở vị trí đầu và cuối của từng record, nếu tồn tại sẽ xóa đi:
<img width="824" alt="Screen Shot 2024-05-28 at 16 00 20" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/dbe31834-d3a8-4d71-8425-d4fb698c9adb">

Thực thi:

<img width="826" alt="Screen Shot 2024-05-28 at 16 00 38" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/28b29e97-5580-48aa-9565-9f6805c30013">

Kết quả:

<img width="573" alt="Screen Shot 2024-05-28 at 16 00 57" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/f50bbf15-3c5e-4c97-8ff6-360c3b5489f7">

Tương tự với các các bảng còn lại:
<img width="816" alt="Screen Shot 2024-05-28 at 16 01 13" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/9374a304-9f0e-4cf7-b932-603252dbd908">

Sau khi đã đưa dữ liệu về đúng định dạng, ta sẽ kiểm tra kiểu dữ liệu của từng bảng để đưa các cột về đúng kiểu dữ liệu:
Ở bảng “staff”, cột “HE_SO_LUONG” đang ở sai kiểu dữ liệu:
<img width="596" alt="Screen Shot 2024-05-28 at 16 01 40" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/0e657ab3-3ee0-49fc-bd01-6e961f214e07">

Thực hiện chuyển đổi kiểu dữ liệu cột HE_SO_LUONG sang int:
<img width="530" alt="Screen Shot 2024-05-28 at 16 01 58" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/54cfba48-f30d-447b-8234-133fd473bf0f">

# 3.Sử dụng SQL để khám phá dữ liệu:
Ta  sẽ sử dụng các câu lệnh SQL để có 1 cái nhìn sâu hơn vào bài toán. Thông qua việc trả lời các câu hỏi, Ta sẽ phân tích về:
• Doanh thu bán hàng
• Hành vi khách hàng
• Hiệu suất nhân viên bán hàng
• Tý giá Hối đoái
=> Kết quả từ các câu lệnh SQl sẽ là input đầu vào cho việc dựng báo cáo (Power BI)

## 3.1 Phân tích doanh thu bán hàng:
Câu hỏi cần trả lời:
- Tổng doanh thu từ các giao dịch bán hàng theo ngày/tháng/năm: (Doanh thu = Unit_price – Sale_off + Chamtra)
- Doanh thu từng cửa hàng theo thời gian
- Doanh thu bán hàng theo cửa hàng/chi nhánh
- Top 10 khách hàng mua nhiều sản phẩm nhất (theo doanh thu)
- Doanh thu bán hàng theo nhân viên bán hàng
- Doanh thu bán hàng theo loại khách hàng (cá nhân, doanh nghiệp)
- Doanh thu bán hàng theo loại giao dịch (bán lẻ, bán buôn)
- Doanh thu tăng trưởng so với tháng trước
- Doanh thu của từng cửa hàng theo từng quý

## 3.2 Phân tích hành vi khách hàng 
- Tần suất mua hàng của khách hàng
- Giá trị đơn hàng trung bình của khách hàng
- Khách hàng thường mua hàng qua nhân viên bán hàng nào
- Doanh thu theo từng loại khách hàng
- Tỷ lệ khách hàng nam và nữ mua hàng theo từng năm

## 3.3 Phân tích hiệu suất nhân viên bán hàng
- Nhân viên bán hàng có tổng doanh số cao nhất theo từng tháng là ai?
- Tổng số giao dịch của mỗi nhân viên bán hàng theo từng tháng?
- Doanh thu trung bình mỗi giao dịch của nhân viên theo từng năm
- Tổng hoa hồng mỗi nhân viên nhận được từng năm
- Nhân viên bán hàng nào có tỷ lệ chiết khấu trả chậm (CHAMTRA) cao nhất theo từng năm?

## 3.4 Phân tích tỷ giá hối đoái 
- Tỷ giá hối đoái trung bình của mỗi loại tiền tệ theo từng tháng?
- Tỷ giá hối đoái cao nhất và thấp nhất của mỗi loại tiền tệ theo từng năm?
- Ngày có tỷ giá hối đoái cao nhất cho mỗi loại tiền tệ?
- Ngày có sự thay đổi tỷ giá lớn nhất của mỗi loại tiền tệ trong năm?
- Tỷ giá hối đoái của mỗi loại tiền tệ vào ngày đầu tiên và ngày cuối cùng của từng tháng?

# 4. Xây dựng Dashboard
Link dashboard: [Link](https://app.powerbi.com/view?r=eyJrIjoiNzUyZTc0ZDMtMzg0ZC00NzA0LTk1ZmYtYzEwYzcxZTUyZWFhIiwidCI6IjZhZWViMGQyLTIxZGQtNDAzZS04YWY5LWZiN2Y1Yzg4ODQyYSIsImMiOjEwfQ%3D%3D)

## 4.1 Preveiew Dashboard Tổng quan kết quả kinh doanh
<img width="806" alt="Screen Shot 2024-05-28 at 16 08 27" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/7f197c12-7ad7-452e-8f46-72dd61b4bbd8">

## 4.2 Previeư Dasboard Phân tích hiệu suất
<img width="808" alt="Screen Shot 2024-05-28 at 16 10 53" src="https://github.com/Ciss48/Ban_Hang_Report/assets/146427357/1d077afd-15bd-4526-a069-27a0c4987759">

