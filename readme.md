# Yêu cầu
Đây là tệp cấu hình cho docker để chạy các hệ thống voip thường dùng là Kamailio và asterisk 
<br> 
Yêu cầu:
- Cần biết  về giao thức sip , iax2 , <br>
- Biết cách sử dụng hệ diều hành linux<br>
- Kiến thức về  docker

# Chuẩn bị
- docker-compose phiên bản 2.26.1
- Image cài asterisk 18
- Image cài kamailio 5.5 và rtpproxy 2.0
- Image của mariadb:10.5

# Chạy

Chuẩn bị
1) copy file init/env.example thành .env
2) Sửa các thông tin về ip và port

Sau đó dùng ``` sudo docker-compose up -d ``` để chạy.<br>
Đăng nhập vào container chứa sip bằng lệnh:
<br>
```
sudo docker exec -it sip bash
```
rồi chạy các lệnh sau để khởi tạo csdl
```
kamdbctl create
kamctl start
```
# Lưu ý
Đây chỉ là cấu hình trong môi tường thử nhiệm , với mục địch tạo điều kiện chạy 1 hệ thống voip nhanh nhất có thể. Với tình hình triến khai phức tạp cần tìm hiểu sau để cấu hình câc tính năn9 nâng cao


# Change log

- 18-12-2021 : add with_nat to default config