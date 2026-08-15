# Day 2: 13/8 ROW_NUMBER, RANK, DENSE_RANK, LAG/LEAD

## Mục tiêu: 

- Phân biệt rõ ràng các hàm ranking bằng ví dụ tự tạo.
- Phân biệt LAG/LEAD

## Đã làm
- Viết 4 querry trên bảng invoice: 
    - Đánh số hoá đơn theo khách hàng
    - Xếp hạng khách hàng theo tổng chi tiêu
    - So sánh doanh thu tháng hiện tại với tháng trước
    - Tìm lần mua tiếp theo của mỗi khách hàng
## Kiến thức chính
### Nhóm Ranking: ROW_NUMBER, RANK, DENSE_RANK

    <hàm>() OVER (
    PARTITION BY <cột chia nhóm>   -- tuỳ chọn, không có = coi cả bảng là 1 nhóm
    ORDER BY <cột sắp xếp>         -- bắt buộc phải có, nếu không kết quả vô nghĩa
    )

#### Bảng phân biệt
| Họ Tên | GPA | ROW_NUMBER | RANK | DENSE_RANK |
| :--- | :--- | :--- | :--- | :--- |
| Nguyễn Quốc Kỳ | 3.8 | 1 | 1 | 1 |
| Lê Thành Nhân | 3.8 | 2 | 1 | 1 |
| Trần Đình Hải | 3.6 | 3 | 3 | 2 |
| Nguyễn Đức Quang | 3.6 | 4 | 3 | 2 |
| Nguyễn Hiếu Ngân | 3.5 | 5 | 5 | 3 |
| Trần Công Minh | 3.4 | 6 | 6 | 4 |

### Nhóm hàm lấy dòng lân cận: LAG, LEAD

    LAG(cột, offset, giá_trị_mặc_định) OVER (PARTITION BY ... ORDER BY ...)

    LEAD(cột, offset, giá_trị_mặc_định) OVER (PARTITION BY ... ORDER BY ...)

- offset: mặc định là 1 (lấy 1 dòng trước/sau)
- Giá trị mặc định: dùng khi không có dòng trước sau (mặc định NULL)

 | Tháng | Doanh thu | Doanh thu tháng trước (LAG) | Doanh thu tháng sau (Lead) |
 | :--- | :--- | :--- | :--- | 
 | 1 | 150 | NULL | 180 |
 | 2 | 180 | 150 | 160 |
 | 3 | 160 | 180 | 170 |
| 4 | 170 | 160 | 210 |
| 5 | 210 | 170 | NULL |
 
### Lỗi gặp phải/Cách xử lý
 - Quên `ORDER BY` trong `OVER` → Kết quả `RANK/ROW_NUMBER` chạy không lỗi nhưng thứ tự vô nghĩa (thứ tự đánh số ngẫu nhiên theo thứ tự vật lý).
 - Dùng `LAG/LEAD` không có `PARTITION BY` khi có nhiều khách hàng → so sánh nhầm giữa 2 dòng khác nhau. Ví dụ để hiểu rõ:

    SELECT 
        customer_id, 
        customer_name, 
        sotien,
        LAG(sotien) OVER (ORDER BY customer_id) as don_truoc
    FROM donhang;

| customer_id | customer_name | sotien | don_truoc |
| :--- | :--- | :--- | :--- |
| 1 | Đức | 3000 | NULL |
| 1 | Đức | 4000 | 3000 |
| 2 | Long | 5000 | 4000 |
| 2 | Long | 6000 | 5000 |