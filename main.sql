-- Mencari 10 transaksi terbesar dari pengguna dengan ID 12476

SELECT 
    seller_id, 
    buyer_id, 
    total AS nilai_transaksi,
    created_at AS tanggal_transaksi
FROM 
    orders
WHERE 
    buyer_id = 12476
ORDER BY 
    nilai_transaksi DESC
LIMIT 10

-- Transaksi per bulan
  
SELECT 
    EXTRACT(YEAR_MONTH FROM created_at) AS tahun_bulan, 
    COUNT(1) AS jumlah_transaksi, 
    SUM(total) AS total_nilai_transaksi
FROM 
    orders
WHERE 
    created_at >= '2020-01-01'
GROUP BY 
    tahun_bulan
ORDER BY 
    tahun_bulan;

-- Pengguna dengan rata-rata transaksi terbesar di Januari 2020

SELECT
    buyer_id,
    COUNT(1) AS jumlah_transaksi,
    AVG(total) AS avg_nilai_transaksi
FROM
    orders
WHERE
    created_at BETWEEN '2020-01-01' AND '2020-02-01'
GROUP BY
    buyer_id
HAVING
    COUNT(1) >= 2
ORDER BY
    avg_nilai_transaksi DESC
LIMIT 10;

-- Transaksi besar di Desember 2019

SELECT 
    u.nama_user AS nama_pembeli, 
    o.total AS nilai_transaksi, 
    o.created_at AS tanggal_transaksi
FROM 
    orders o
INNER JOIN 
    users u ON o.buyer_id = u.user_id
WHERE 
    o.created_at BETWEEN '2019-12-01' AND '2019-12-31' 
    AND o.total >= 20000000
ORDER BY 
    nama_pembeli;
  
-- Kategori Produk Terlaris di 2020

SELECT 
    p.category, 
    SUM(od.quantity) AS total_quantity, 
    SUM(price) AS total_price 
FROM 
    orders o
INNER JOIN 
    order_details od ON o.order_id = od.order_id
INNER JOIN 
    products p ON od.product_id = p.product_id
WHERE 
    o.created_at >= '2020-01-01' 
    AND o.delivery_at IS NOT NULL 
GROUP BY 
    p.category
ORDER BY 
    total_quantity DESC
LIMIT 5;

-- Mencari pembeli high value

SELECT
    u.nama_user AS nama_pembeli,
    COUNT(o.order_id) AS jumlah_transaksi,
    SUM(o.total) AS total_nilai_transaksi,
    MIN(o.total) AS min_nilai_transaksi
FROM
    orders o
INNER JOIN
    users u ON o.buyer_id = u.user_id
GROUP BY
    u.user_id, u.nama_user
HAVING
    COUNT(o.order_id) > 5 AND MIN(o.total) > 2000000
ORDER BY
    total_nilai_transaksi DESC;

-- Mencari Dropshipper

SELECT
    u.nama_user AS nama_pembeli,
    COUNT(o.order_id) AS jumlah_transaksi,
    COUNT(DISTINCT o.kodepos) AS distinct_kodepos,
    SUM(o.total) AS total_nilai_transaksi,
    AVG(o.total) AS avg_nilai_transaksi
FROM
    orders o
INNER JOIN
    users u ON o.buyer_id = u.user_id
GROUP BY
    u.user_id, u.nama_user
HAVING
    COUNT(o.order_id) >= 10 AND 
    COUNT(o.order_id) = COUNT(DISTINCT o.kodepos)
ORDER BY
    jumlah_transaksi DESC;

-- Mencari Reseller Offline

SELECT
    u.nama_user AS nama_pembeli,
    COUNT(o.order_id) AS jumlah_transaksi,
    SUM(o.total) AS total_nilai_transaksi,
    AVG(o.total) AS avg_nilai_transaksi,
    AVG(sd.total_quantity) AS avg_quantity_per_transaksi
FROM
    orders o
INNER JOIN
    users u ON o.buyer_id = u.user_id
INNER JOIN
    (SELECT 
        order_id, 
        SUM(quantity) AS total_quantity 
    FROM 
        order_details 
    GROUP BY 
        order_id) sd ON o.order_id = sd.order_id
WHERE
    o.kodepos = u.kodepos
GROUP BY
    u.user_id, u.nama_user
HAVING
    COUNT(o.order_id) >= 8 AND 
    AVG(sd.total_quantity) > 10
ORDER BY
    total_nilai_transaksi DESC;

-- Pembeli sekaligus penjual

SELECT
    u.nama_user AS nama_pengguna,
    b.jumlah_transaksi_beli,
    s.jumlah_transaksi_jual
FROM
    users u
INNER JOIN 
    (
        SELECT 
            buyer_id, 
            COUNT(*) AS jumlah_transaksi_beli
        FROM 
            orders
        GROUP BY 
            buyer_id
    ) AS b ON u.user_id = b.buyer_id
INNER JOIN
    (
        SELECT 
            seller_id, 
            COUNT(*) AS jumlah_transaksi_jual
        FROM 
            orders
        GROUP BY 
            seller_id
    ) AS s ON u.user_id = s.seller_id
WHERE
    b.jumlah_transaksi_beli >= 7
ORDER BY 
    1;

-- Lama transaksi dibayar

SELECT
    EXTRACT(YEAR_MONTH FROM created_at) AS tahun_bulan,
    COUNT(1) AS jumlah_transaksi,
    AVG(DATEDIFF(paid_at, created_at)) AS avg_lama_dibayar,
    MIN(DATEDIFF(paid_at, created_at)) AS min_lama_dibayar,
    MAX(DATEDIFF(paid_at, created_at)) AS max_lama_dibayar
FROM
    orders
WHERE
    paid_at IS NOT NULL
GROUP BY
    tahun_bulan
ORDER BY
    tahun_bulan;
