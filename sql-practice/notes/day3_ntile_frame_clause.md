# Day 3 (14/8) NTILE & Frame Clause (ROWS/RANGE BETWEEN)

## Mục tiêu
- Nắm vững cú pháp và cơ chế phân bổ dòng của `NTILE(n)`.
- Phân biệt rõ ràng `ROWS BETWEEN` và `RANGE BETWEEN` trong Window Functions.
- Thành thạo kỹ thuật tính Running Total (tổng dồn) và Moving Average (trung bình trượt).
- Hiểu cái bẫy của Frame Clause mặc định trong PostgreSQL để tránh lỗi âm thầm.

## Đã làm
- Học lý thuyết về `NTILE(n)` và công thức chia nhóm khi số dòng không chia hết.
- Học cú pháp và các điểm mốc trong Frame Clause (`UNBOUNDED PRECEDING`, `CURRENT ROW`, `N PRECEDING`, v.v.).
- Viết và thực hành các bài tập query trên database `Chinook`:
  1. **Running total**: Tính tổng doanh thu dồn theo từng ngày trên bảng `invoice`.
  2. **Moving average**: Tính trung bình trượt doanh thu 7 ngày gần nhất.
  3. **Bài tập bẫy lỗi (Demo Frame)**: Tự tạo dữ liệu thử nghiệm để so sánh kết quả giữa `ROWS` và `RANGE`.
- Hoàn thành checklist tự đánh giá và tổng kết ghi chú trong ngày.

---

## Kiến thức chính

### 1. Hàm NTILE(n)

Gọi tổng số dòng là `R`, `NTILE(n)` chia tập kết quả (đã `ORDER BY`) thành `n` nhóm gần bằng nhau nhất có thể và đánh số từ 1 đến `n`.

**Công thức phân bổ khi số dòng ($R$) không chia hết cho $n$:**
- Số dòng cơ bản mỗi nhóm = $\lfloor R / n \rfloor$
- Số dòng dư = $R \bmod n$
- $R \bmod n$ nhóm đầu tiên sẽ nhận thêm 1 dòng.

#### Ví dụ phân bổ ($R = 59$, $n = 4$):
- $\lfloor 59 / 4 \rfloor = 14$, dư = $59 - (14 \times 4) = 3$
- Nhóm 1, 2, 3: mỗi nhóm có 15 dòng ($14 + 1$)
- Nhóm 4: có 14 dòng

```sql
SELECT
    customer_id,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile
FROM customer_totals;
```
### 2. Cú pháp & Các điểm mốc trong Frame Clause

``` SQL
<hàm> OVER (
    [PARTITION BY cột_nhóm]
    [ORDER BY cột_sắp_xếp]
    [ROWS | RANGE BETWEEN <điểm_bắt_đầu> AND <điểm_kết_thúc>]
)
```
#### Các mốc thường dùng:
`UNBOUNDED PRECEDING`: Từ dòng đầu tiên của partition.

`N PRECEDING`: `N` dòng trước dòng hiện tại.

`CURRENT ROW`: Dòng hiện tại.

`N FOLLOWING`: `N` dòng sau dòng hiện tại.

`UNBOUNDED FOLLOWING`: Đến dòng cuối cùng của partition.

#### Lỗi gặp phải/Cách xử lý
##### 1. Bẫy mặc định RANGE khi không khai báo frame:
- Lỗi / Hiện tượng: Viết SUM(val) OVER (ORDER BY date) khiến các dòng cùng ngày nhận chung kết quả tổng của cả ngày thay vì cộng dồn từng dòng.
``` SQL 
    SELECT
        invoice_date,
        SUM(total) OVER (ORDER BY invoice_date) AS running_total
    FROM invoice;
```
 | invoice_date | total | running_total | 
 | :--- | :--- | :--- | 
 | 2024-01-01 | 100 | 150 |
 | 2024-01-01 | 50 | 150 | 

 SỬA

 ``` SQL 
    SELECT
        invoice_date,
        SUM(total) OVER (
            ORDER BY invoice_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS running_total
    FROM invoice;
```
 | invoice_date | total | running_total | 
 | :--- | :--- | :--- | 
 | 2024-01-01 | 100 | 100 |
 | 2024-01-01 | 50 | 150 | 

 ##### 2. Lấn cấn giữa việc gom nhóm tổng ngày (GROUP BY) và việc cộng dồn theo thời gian (OVER)
- Ví dụ: Muốn tính tổng doanh thu theo ngày, sau đó tính doanh thu tích lũy qua các ngày.

``` sql
SELECT 
    invoice_date::date,
    SUM(total) AS daily_revenue,
    SUM(total) OVER (ORDER BY invoice_date::date) AS running_total 
FROM invoice
GROUP BY invoice_date::date;
-- ERROR: column "invoice.total" must appear in the GROUP BY clause or be used in an aggregate function
```
- Sửa
``` sql
-- ✅ CÁCH 1: Dùng hàm gộp lồng nhau SUM(SUM(...))
SELECT 
    invoice_date::date AS ngay,
    SUM(total) AS daily_revenue,
    SUM(SUM(total)) OVER (
        ORDER BY invoice_date::date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM invoice
GROUP BY invoice_date::date;

-- ✅ CÁCH 2: Dùng CTE 
WITH daily AS (
    SELECT 
        invoice_date::date AS ngay,
        SUM(total) AS daily_revenue
    FROM invoice
    GROUP BY invoice_date::date
)
SELECT 
    ngay,
    daily_revenue,
    SUM(daily_revenue) OVER (
        ORDER BY ngay 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total
FROM daily;
```