-- Mỗi khách hàng, sau lần mua này bao lâu thì họ quay lại mua tiếp?

SELECT
    customer_id,
    invoice_date,
    LEAD(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date) AS next_purchase_date,
    LEAD(invoice_date) OVER (PARTITION BY customer_id ORDER BY invoice_date) - invoice_date AS days_until_next_purchase
FROM invoice
ORDER BY customer_id, invoice_date;