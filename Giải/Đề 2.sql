---Đề 2
CREATE DATABASE QLBenhVien
GO

USE QLBenhVien
GO

CREATE TABLE BenhVien (
	MaBV CHAR(5) PRIMARY KEY, 
	TenBV NVARCHAR(30), 
	DiaChi NVARCHAR(30)
)

CREATE TABLE KhoaKham(
	MaKhoa CHAR(5) PRIMARY KEY, 
	TenKhoa NVARCHAR(30), 
	SoBenhNhan INT, 
	MaBV char(5) FOREIGN KEY(MaBV) REFERENCES BenhVien(MaBV)
)

CREATE TABLE BenhNhan (
	MaBN CHAR(5) PRIMARY KEY, 
	HoTen NVARCHAR(30), 
	GioiTinh NVARCHAR(20), 
	SoNgayNV INT, 
	MaKhoa CHAR(5) FOREIGN KEY(MaKhoa) REFERENCES KhoaKham(MaKhoa)
)
INSERT INTO BenhVien VALUES 
('BV01', N'Bệnh viện 1', N'Hà Nội'),
('BV02', N'Bệnh viện 2', N'Hà Nội'),
('BV03', N'Bệnh viện 3', N'Hà Nội')


INSERT INTO KhoaKham VALUES
('K01', N'Khoa khám 1', 3, 'BV01'), 
('K02', N'Khoa khám 2', 4, 'BV01'),
('K03', N'Khoa khám 3', 120, 'BV03')

INSERT INTO BenhNhan VALUES 
('BN01', N'Bệnh nhân 1', N'Nữ', 20, 'K01'),
('BN02', N'Bệnh nhân 2', N'Nam', 10, 'K02'),
('BN03', N'Bệnh nhân 3', N'Nữ', 21, 'K03'),
('BN04', N'Bệnh nhân 4', N'Nam', 12, 'K02'),
('BN05', N'Bệnh nhân 5', N'Nữ', 4, 'K03') 

SELECT * FROM BenhVien
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan

--Câu 2: Tạo view
GO
CREATE VIEW v_cau2 
AS
SELECT TenBV, TenKhoa, COUNT(BenhNhan.MaBN) AS N'Số bệnh nhân'
FROM BenhVien INNER JOIN KhoaKham 
ON BenhVien.MaBV = KhoaKham.MaBV
INNER JOIN BenhNhan
ON KhoaKham.MaKhoa = BenhNhan.MaKhoa
WHERE GioiTinh = N'Nữ'
GROUP BY BenhVien.TenBV, KhoaKham.TenKhoa

--thực thi
SELECT * FROM v_cau2

--Câu 3: tạo function
GO
CREATE FUNCTION fn_cau3 (@tenBV NVARCHAR(30), @tenKhoa NVARCHAR(30))
RETURNS MONEY
AS
BEGIN
	DECLARE @tongTien MONEY
	SELECT @tongTien = (
		SELECT SUM(SoNgayNV * 100000)
		FROM BenhVien INNER JOIN KhoaKham
		ON BenhVien.MaBV = KhoaKham.MaBV
		INNER JOIN BenhNhan
		ON KhoaKham.MaKhoa = BenhNhan.MaKhoa
		WHERE TenBV = @tenBV AND TenKhoa = @tenKhoa
	)
	RETURN @tongTien
END
--thực thi
SELECT dbo.fn_cau3(N'Bệnh viện 3', N'Khoa khám 3') AS N'Tổng Tiền'

SELECT * FROM BenhVien
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan

--Câu 4: tạo trigger
GO
CREATE TRIGGER t_cau4
ON BenhNhan
FOR UPDATE
AS
BEGIN
	DECLARE @soBNKhoaMoi INT 
	SELECT @soBNKhoaMoi = (
		SELECT SoBenhNhan 
		FROM KhoaKham INNER JOIN inserted
		ON KhoaKham.MaKhoa = inserted.MaKhoa
	)
	IF(@soBNKhoaMoi >= 100)
		BEGIN
			RAISERROR(N'không thể chuyển khoa', 16, 1)
			ROLLBACK TRAN
		END
	ELSE 
		BEGIN
			--update khoa cũ
			UPDATE KhoaKham
			SET SoBenhNhan = SoBenhNhan - 1
			WHERE MaKhoa = (SELECT MaKhoa FROM deleted)
			--update khoa mới chuyển tới
			UPDATE KhoaKham
			SET SoBenhNhan = SoBenhNhan + 1
			WHERE MaKhoa = (SELECT MaKhoa FROM inserted)
		END
END

--thực thi
--THÀNH CÔNG
UPDATE BenhNhan 
SET MaKhoa = 'K01'
WHERE MaBN = 'BN02'
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan
--THẤT BẠI
UPDATE BenhNhan 
SET MaKhoa = 'K03'
WHERE MaBN = 'BN01'
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan

