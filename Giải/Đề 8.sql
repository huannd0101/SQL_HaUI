--Đề 8
USE master
GO

DROP DATABASE QLBanHang
GO

CREATE DATABASE QLBanHang
GO

USE QLBanHang
GO

CREATE TABLE CongTy (
	MaCongTy CHAR(5) PRIMARY KEY, 
	TenCongTY NVARCHAR(30), 
	DiaChi NVARCHAR(30)
)

CREATE TABLE SanPham (
	MaSanPham CHAR(5) PRIMARY KEY, 
	TenSanPham NVARCHAR(30), 
	SoLuongCo INT, 
	GiaBan MONEY
)

CREATE TABLE CungUng (
	MaCongTy CHAR(5), 
	MaSanPham CHAR(5), 
	SoLuongCungUng INT, 
	NgayCungUng DATE, 
	PRIMARY KEY(MaCongTy, MaSanPham), 
	CONSTRAINT pk_ct FOREIGN KEY(MaCongTy) REFERENCES CongTy(MaCongTy), 
	CONSTRAINT pk_sp FOREIGN KEY(MaSanPham) REFERENCES SanPham(MaSanPham)
)

INSERT INTO CongTy VALUES
('CT01', N'Công ty 1', N'Hà Nội'), 
('CT02', N'Công ty 2', N'Điện Biên'), 
('CT03', N'Công ty 3', N'Hà Nam')

INSERT INTO SanPham VALUES
('SP01', N'Sản phẩm 1', 10, 20000),
('SP02', N'Sản phẩm 2', 20, 30000),
('SP03', N'Sản phẩm 3', 30, 40000) 

INSERT INTO CungUng VALUES
('CT01', 'SP01', 10, '2021-01-01'),
('CT01', 'SP02', 20, '2021-02-01'),
('CT01', 'SP03', 30, '2021-03-01'),
('CT02', 'SP01', 40, '2021-04-01'),
('CT03', 'SP01', 50, '2021-05-01')

SELECT * FROM CongTy
SELECT * FROM SanPham
SELECT * FROM CungUng

--CÂU 2: TẠO HÀM
GO
CREATE FUNCTION fn_cau2 (@tenCT NVARCHAR(30), @ngayCungUng DATE)
RETURNS @table TABLE (TenSP NVARCHAR(30), SoLuong INT, GiaBan MONEY)
AS
BEGIN
	INSERT INTO @table
	SELECT TenSanPham, SoLuongCo, GiaBan
	FROM CongTy INNER JOIN CungUng
	ON CongTy.MaCongTy = CungUnG.MaCongTy
	INNER JOIN SanPham
	ON SanPham.MaSanPham = CungUng.MaSanPham
	WHERE TenCongTY = @tenCT AND NgayCungUng = @ngayCungUng

	RETURN
END

--THỰC THI
GO
SELECT * FROM dbo.fn_cau2 (N'Công ty 1', '2021-02-01')

--Câu 3: Tạo proc
GO
CREATE PROC	p_cau3 (@maCT CHAR(5), @tenCT NVARCHAR(30), @diaChi NVARCHAR(30), @kq INT OUTPUT)
AS
BEGIN
	IF EXISTS(SELECT * FROM CongTy WHERE TenCongTY = @tenCT)
		BEGIN
			SET @kq = 1
			PRINT N'Tên công ty đã tồn tại'
			RETURN
		END
	--THÊM
	INSERT INTO CongTy VALUES (@maCT, @tenCT, @diaChi)
	SET @kq = 0
END

--Thực thi
--không thành công
GO
DECLARE @kq INT
EXEC p_cau3 'CT04', N'Công ty 1', N'Hải Dương', @kq OUTPUT
SELECT @kq AS N'Kết quả'
SELECT * FROM CongTy 

--thành công
GO
DECLARE @kq INT
EXEC p_cau3 'CT04', N'Công ty 4', N'Hải Dương', @kq OUTPUT
SELECT @kq AS N'Kết quả'
SELECT * FROM CongTy 

--Câu 4: tạo trigger
GO
CREATE TRIGGER tg_cau4 
ON CungUng 
FOR UPDATE
AS
BEGIN
	DECLARE @soLuongCungUngCu INT = (SELECT SoLuongCungUng FROM deleted)
	DECLARE @soLuongCungUngMoi INT = (SELECT SoLuongCungUng FROM inserted)
	DECLARE @soLuongCo INT = (
		SELECT SoLuongCO 
		FROM inserted INNER JOIN SanPham 
		ON inserted.MaSanPham = SanPham.MaSanPham
	)
	DECLARE @soLuongChenhLech INT = @soLuongCungUngMoi - @soLuongCungUngCu
	IF(@soLuongChenhLech <= @soLuongCo)
		BEGIN 
			UPDATE SanPham 
			SET SoLuongCo = SoLuongCo - @soLuongChenhLech
			WHERE MaSanPham = (SELECT MaSanPham FROM inserted)
		END
	ELSE 
		BEGIN
			RAISERROR(N'Không thể cập nhập vì số lượng không đủ', 16, 1)
			ROLLBACK TRAN
		END
END

--Thực thi
--Không thành công
UPDATE CungUng
SET SoLuongCungUng = 21
WHERE MaCongTy = 'CT01' AND MaSanPham = 'SP01'

--Thành công
UPDATE CungUng
SET SoLuongCungUng = 20
WHERE MaCongTy = 'CT01' AND MaSanPham = 'SP01'

SELECT * FROM SanPham
SELECT * FROM CungUng