-- Đánh số thứ tự các hoá đơn của mỗi khách hàng theo thời gian mua
SELECT
    customer_id,
    invoice_id,
    invoice_date,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id,
        ORDER BY invoice_date, invoice_id
    ) AS invoice_seq
FROM invoice
ORDER BY customer_id, invoice_seq