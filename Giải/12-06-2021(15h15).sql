USE master
GO

DROP DATABASE QLNhaHang 
GO

CREATE DATABASE QLNhaHang 
GO

USE QLNhaHang 
GO

CREATE TABLE Ban (
	MaBan CHAR(5) PRIMARY KEY,
	ViTri NVARCHAR(30),
	SoChoNgoi INT
)

CREATE TABLE Mon (
	MaMon CHAR(5) PRIMARY KEY,
	TenMon NVARCHAR(30),
	MauSac NVARCHAR(30), 
	SoLuong INT,
	Giaban MONEY,
	Mota NVARCHAR(100)
)

CREATE TABLE HoaDon (
	SoHD CHAR(5) PRIMARY KEY,
	MaBan CHAR(5),
	MaMon CHAR(5),
	SoLuongDat INT,
	NgayDat DATE, 
	CONSTRAINT fk_hoaDon_ban FOREIGN KEY (MaBan) REFERENCES Ban(MaBan), 
	CONSTRAINT fk_hoaDon_mon FOREIGN KEY (MaMon) REFERENCES Mon(MaMon)
)

INSERT INTO Ban VALUES 
('B01', N'Tầng 1', 4), 
('B02', N'Tầng 2', 5), 
('B03', N'Tầng 3', 6)

INSERT INTO Mon VALUES 
('M01', N'Cá', N'Xanh', 10, 2000000, N'Canh cá'),
('M02', N'Rau cải', N'Xanh', 20, 3000000, N'Canh rau'),
('M03', N'Thịt lợn', N'Đỏ', 30, 4000000, N'Thịt nướng')

INSERT INTO HoaDon VALUES 
('HD01', 'B01', 'M01', 11, '2021-01-01'),
('HD02', 'B01', 'M02', 12, '2021-01-02'),
('HD03', 'B01', 'M01', 13, '2021-01-03'),
('HD04', 'B02', 'M02', 14, '2021-01-04'),
('HD05', 'B03', 'M03', 15, '2021-01-05')

SELECT * FROM Ban
SELECT * FROM Mon
SELECT * FROM HoaDon

--Câu 2:
GO
CREATE FUNCTION fn_cau2 (@viTri NVARCHAR(30), @ngayDat DATE) 
RETURNS MONEY
BEGIN
	DECLARE @tongTien MONEY

	SELECT @tongTien = (
		SELECT SUM(SoLuongDat * Giaban)
		FROM Ban INNER JOIN HoaDon
		ON Ban.MaBan = HoaDon.MaBan
		INNER JOIN Mon
		ON Mon.MaMon = HoaDon.MaMon
		WHERE ViTri = @viTri AND NgayDat = @ngayDat
	)

	RETURN @tongTien
END

--Thực thi
--SAI NGÀY
SELECT dbo.fn_cau2(N'Tầng 1', '1999-01-01') AS N'Giá bán'
--SAI VỊ TRÍ
SELECT dbo.fn_cau2(N'Tầng hầm', '2021-01-01') AS N'Giá bán'
--ĐÚNG
SELECT dbo.fn_cau2(N'Tầng 1', '2021-01-01') AS N'Giá bán'

--Câu 3:
GO
CREATE PROC p_cau3 (@maHD CHAR(5), @soLuongDat INT, @ngayDat DATE, @maBan CHAR(5), @maMon CHAR(5), @kq INT OUTPUT)
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM Ban WHERE MaBan = @maBan))
		BEGIN
			PRINT N'Mã bàn không tồn tại'
			SET @kq = 1
			RETURN
		END
	ELSE IF(NOT EXISTS(SELECT * FROM Mon WHERE MaMon = @maMon))
		BEGIN
			PRINT N'Mã món không tồn tại'
			SET @kq = 2
			RETURN
		END
	ELSE 
		BEGIN
			INSERT INTO HoaDon VALUES (@maHD, @maBan, @maMon, @soLuongDat, @ngayDat)
			SET @kq = 0
		END
END

--THỰC THI
--KHÔNG THÀNH CÔNG 
GO
DECLARE @KQ INT
EXEC p_cau3 'HD06', 15, '2021-01-05', 'B00', 'M03', @KQ OUTPUT
SELECT @KQ AS N'kết quả'
--KHÔNG THÀNH CÔNG
GO
DECLARE @KQ INT
EXEC p_cau3 'HD06', 15, '2021-01-05', 'B01', 'M00', @KQ OUTPUT
SELECT @KQ AS N'kết quả'
--THÀNH CÔNG
GO
DECLARE @KQ INT
EXEC p_cau3 'HD06', 15, '2021-01-05', 'B03', 'M03', @KQ OUTPUT
SELECT @KQ AS N'kết quả'
SELECT * FROM HoaDon

--Câu 4:
GO
CREATE TRIGGER tg_cau4 
ON HoaDon
FOR INSERT 
AS
BEGIN
	DECLARE @soLuongDat INT  = (SELECT SoLuongDat FROM inserted)
	DECLARE @soLuong INT  = (SELECT SoLuong FROM inserted INNER JOIN Mon ON inserted.MaMon = Mon.MaMon)
	IF(@soLuongDat < @soLuong)
		BEGIN
			UPDATE Mon 
			SET SoLuong = SoLuong - @soLuongDat
			WHERE MaMon = (SELECT MaMon FROM inserted)
		END
	ELSE 
		BEGIN
			RAISERROR(N'Không đủ số lượng ', 16, 1)
			ROLLBACK TRAN
		END
END

--THỰC THI
--THÁT BẠI
INSERT INTO HoaDon VALUES ('HD07', 'B03', 'M01', 20, '2021-01-01')
SELECT * FROM Mon
SELECT * FROM HoaDon
--THÀNH CÔNG
INSERT INTO HoaDon VALUES ('HD07', 'B03', 'M01', 5, '2021-01-01')
SELECT * FROM Mon
SELECT * FROM HoaDon




create trigger tg_cau4
on HoaDon
for insert
as
begin
	if exists ( select * from inserted join Mon on inserted.MaMon = Mon.MaMon
				where SoLuong < SoLuongDat)
	begin
	print N'Số lượng đặt lớn hơn số lượng có'
	rollback tran
	return 
	end
	update Mon
	set	SoLuong = SoLuong - SoLuongDat
	from Mon join inserted on Mon.MaMon = inserted.MaMon
end
select * from HoaDon join Ban on HoaDon.MaBan = Ban.MaBan
join Mon on HoaDon.MaMon = Mon.MaMon
-- TH sau số lượng đặt  > số lượng 
insert into HoaDon values ('HD07', 'Ban2', 'Mon3', 30, '1-1-2021')
-- TH đúng
insert into HoaDon values ('HD07', 'Ban2', 'Mon3', 2, '1-1-2021')
