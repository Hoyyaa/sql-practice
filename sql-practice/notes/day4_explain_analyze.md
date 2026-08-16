# Day 4 (15/8): EXPLAIN | EXPLAIN ANALYZE
## Mục tiêu ngày
- Học đọc `EXPLAIN ANALYZE` cho các câu query đã viết từ ngày 1 - 3.
- Nhận diện `Seq Scan / Index Scan`.
- Đọc cây plan đúng thứ tự.
- Phân biệt `cost` (ước tính) và `actual time` (thực đo).
## Kiến thức chính
### 1. EXPLAIN - EXPLAIN ANALYZE:
| | `EXPLAIN` | `EXPLAIN ANALYZE` |
| :--- | :--- | :--- | 
| Chạy câu lệnh thật | Không - chỉ ước tính | Có, chạy thật, đo thời gian |
| Trả về | `cost` (ước tính) | `cost` + `actual time` (thực đo) |
| An toàn với `UPDATE/DELETE` | An toàn | Nguy hiểm - sửa/xoá dữ liệu thật |

### 2. Nguyên tắc đọc cây plan:

- Node thụt lề sâu nhất chạy trước, node ngoài cùng chạy sau cùng và bọc kết quả các node bên trong.
- Đọc từ trong ra ngoài, từ dưới lên trên.

### 3. Các thuật ngữ

| **Thuật ngữ** | **Ý nghĩa** |
| :--- | :--- |
| `Seq Scan` | Quét toàn bộ bảng từ đầu đến cuối để tìm dòng thỏa điều kiện - nhanh nhất với bảng nhỏ, không phải lúc nào cũng xấu.|
| `Index Scan` | Dùng index để tìm thẳng đến dòng cần - lợi thế khi bảng lớn và chỉ cần ít dòng |
| `Nested Loop` | Với mỗi dòng bảng ngoài, tìm dòng khớp ở bảng trong - hợp lý khi 1 bảng nhỏ  |
| `Hash Join` | Tạo bảng băm (hash table) trên bộ nhớ cho bảng nhỏ hơn, rồi dùng bảng lớn quét qua để so khớp.  |
| `WindowAgg` | Node xử lý riêng cho OVER(), thường nằm ngay dưới Sort |
| `cost=X...Y` | X là chi phí lấy dòng đầu tiên; Y là chi phí hoàn thành toàn bộ. Đây là đơn vị ước tính nội bộ của Postgres  |
| `actual time=X...Y` | Thời gian thực đo (ms) |
| `rows=N` | Số dòng Postgres dự tính (rows=) hoặc số dòng thực tế thu được (actual rows=). Nếu hai số này lệch nhau quá lớn, tức là dữ liệu thống kê bảng đã cũ.  |

### Minh hoạ
#### Query 1: Lọc bằng WHERE

``` sql
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM invoice WHERE customer_id = 5;
```
``` sql
Seq Scan on invoice  (cost=0.00..15.15 rows=7 width=64) (actual time=0.012..0.031 rows=7 loops=1)
  Filter: (customer_id = 5)
  Rows Removed by Filter: 405
Planning Time: 0.085 ms
Execution Time: 0.048 ms
```
| **Bước** | **Đọc kết quả** |
| :--- | :--- |
|1. Node trong cùng | Chỉ có 1 node duy nhất: Seq Scan on invoice — quét lần lượt cả 412 dòng, giữ lại 7 dòng khớp customer_id = 5, loại 405 dòn|
|2. Node ngoài | Không có — plan chỉ 1 tầng, kết quả Seq Scan chính là kết quả cuối  |
|3. Ước tính - thực tế  | `rows=7` khớp `actual rows=7` → thống kê bảng đang chính xác |
|4. Vì sao Seq Scan | Bảng invoice chỉ 412 dòng — quá nhỏ để Index Scan có lợi, mở index còn tốn hơn quét thẳng
|5. Execution Time | 0.048 ms — mốc để so sánh "trước/sau tối ưu"|


