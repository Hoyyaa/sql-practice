# sql-practice

## Day 1: 12/8 Logical Query Processing Order

### Mục tiêu: 

- Nắm vững **Logical Query Processing Order** (Thứ tự thực thi logic của truy vấn SQL) trong PostgreSQL.
- Hiểu rõ bản chất vì sao câu lệnh SQL thực thi khác với thứ tự cú pháp người lập trình viết.
- Thiết lập môi trường thực hành chuẩn với Docker và dataset mẫu Chinook

### Đã làm:
    
- Setup Docker + Postgres 16, import dataset Chinook, sanity check 3 bảng chính (`customer`, `invoice`, `track`) — số dòng khớp, import thành công.
- Thử `WHERE` dùng alias từ `SELECT` → lỗi `column does not exist`. Xác nhận nguyên nhân: `WHERE` chạy trước `SELECT` trong thứ tự thực thi logic.

### Kiến thức chính

#### Thứ tự thực thi Logical Execution Order

```
FROM → JOIN → WHERE → GROUP BY → HAVING → SELECT → DISTINCT → ORDER BY → LIMIT
```

| Bước | Mệnh đề (Clause) | Bản chất hoạt động & Lưu ý kỹ thuật |
| :--- | :--- | :--- |
| **1 - 2** | `FROM` $\rightarrow$ `JOIN` | Xác định bảng nguồn và thực hiện ghép bảng (tạo bảng ảo ban đầu). |
| **3** | `WHERE` | **Lọc từng dòng dữ liệu (Row-level filter).** Chạy TRƯỚC `SELECT`, do đó các Alias tạo ra ở `SELECT` chưa tồn tại. |
| **4 - 5** | `GROUP BY` $\rightarrow$ `HAVING` | Gom nhóm dữ liệu và lọc trên kết quả gom nhóm (Aggregate filter). |
| **6** | `SELECT` | **Tạo cột, tính toán biểu thức & gán biệt danh (Alias).** Đến bước này Alias mới chính thức xuất hiện! |
| **7 - 9** | `DISTINCT` $\rightarrow$ `ORDER BY` $\rightarrow$ `LIMIT` | Loại bỏ trùng lặp, sắp xếp và giới hạn kết quả trả về client. |



### Lỗi gặp phải/ cách xử lý:

- Lỗi column does not exist khi dùng alias trong WHERE → sửa bằng cách lặp lại biểu thức gốc thay vì alias, hoặc dùng CTE/subquery nếu cần tái sử dụng.

    SELECT CONCAT(first_name, ' ', last_name) as full_name FROM customer
    where full_name = 'Frank Harris   

- Kết quả: ERROR: column "full_name" does not exist

- Cách xử lý: 
    - Lặp lại biểu thức gốc:

    SELECT CONCAT(first_name, ' ', last_name) as full_name FROM customer

    WHERE CONCAT(first_name, ' ', last_name) = 'Frank Harris'

    - Sử dụng CTE: 

        WITH customer_fullname AS (
            SELECT CONCAT(first_name, ' ', last_name) AS full_name
            FROM Customer
        )
        SELECT full_name
        FROM customer_fullname
        WHERE full_name = 'Frank Harris';

