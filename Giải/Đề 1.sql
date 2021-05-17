---Đề 1
CREATE DATABASE QLBenhVien
GO

USE QLBenhVien
GO

CREATE TABLE BenhVien (
	MaBV CHAR(5) PRIMARY KEY, 
	TenBV NVARCHAR(30)
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
	NgaySinh DATETIME, 
	GioiTinh NVARCHAR(20), 
	SoNgayNV INT, 
	MaKhoa CHAR(5) FOREIGN KEY(MaKhoa) REFERENCES KhoaKham(MaKhoa)
)
INSERT INTO BenhVien VALUES 
('BV01', N'Bệnh viện 1'),
('BV02', N'Bệnh viện 2'),
('BV03', N'Bệnh viện 3')


INSERT INTO KhoaKham VALUES
('K01', N'Khoa khám 1', 3, 'BV01'), 
('K02', N'Khoa khám 2', 4, 'BV01'),
('K03', N'Khoa khám 3', 120, 'BV03')

INSERT INTO BenhNhan VALUES 
('BN01', N'Bệnh nhân 1', '2020-09-16',  N'Nữ', 20, 'K01'),
('BN02', N'Bệnh nhân 2', '2020-08-16',  N'Nam', 10, 'K02'),
('BN03', N'Bệnh nhân 3', '2020-07-16',  N'Nữ', 21, 'K03'),
('BN04', N'Bệnh nhân 4', '2020-06-16',  N'Nam', 12, 'K02'),
('BN05', N'Bệnh nhân 5', '2020-05-16',  N'Nữ', 4, 'K03') 

SELECT * FROM BenhVien
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan

--Câu 2: Tạo hàm
GO
CREATE FUNCTION f_cau2 (@gioiTinh NVARCHAR(20))
RETURNS @bang TABLE(TenBV NVARCHAR(30), TongSoBN int)
AS
BEGIN
	INSERT INTO @bang
		SELECT TenBV, COUNT(BenhNhan.MaBN) AS N'Tổng số bệnh nhân'
		FROM BenhVien INNER JOIN KhoaKham
		ON BenhVien.MaBV = KhoaKham.MaBV
		INNER JOIN BenhNhan 
		ON BenhNhan.MaKhoa = KhoaKham.MaKhoa
		WHERE GioiTinh = @gioiTinh
		GROUP BY KhoaKham.MaKhoa, TenBV
	RETURN
END

--thực thi
GO
SELECT * FROM f_cau2(N'Nữ')

--Câu 3: tạo thủ tục
GO
CREATE PROC p_cau3 (@tenKhoa NVARCHAR(30), @tenBV NVARCHAR(30))
AS
BEGIN 
	IF(NOT EXISTS(SELECT * FROM BenhVien INNER JOIN KhoaKham
				ON BenhVien.MaBV = KhoaKham.MaBV
				WHERE TenKhoa = @tenKhoa AND TenBV = @tenBV))
		BEGIN
			DECLARE @notification NVARCHAR(100)
			SET @notification = N'Không có ' + @tenKhoa + N' hoặc bệnh viện ' + @tenBV
			RAISERROR(@notification, 16, 1)
			ROLLBACK TRANSACTION
		END	
	ELSE 
		BEGIN
			SELECT SUM(SoBenhNhan) AS N'Tổng số bệnh nhân' 
			FROM BenhVien INNER JOIN KhoaKham
			ON BenhVien.MaBV = KhoaKham.MaBV
			WHERE TenKhoa = @tenKhoa AND TenBV = @tenBV
		END
END

--thực thi
EXEC p_cau3 N'Khoa khám 1', N'Bệnh viện 1'

SELECT * FROM BenhVien
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan

--Câu 4: tạo trigger
GO
CREATE TRIGGER t_cau4
ON BenhNhan
FOR INSERT
AS
BEGIN
	DECLARE @soBNTrongKhoa INT = 
		(SELECT SoBenhNhan FROM KhoaKham INNER JOIN inserted 
			ON KhoaKham.MaKhoa = inserted.MaKhoa)
	IF(@soBNTrongKhoa > 100)
		BEGIN
			DECLARE @tenKhoa NVARCHAR(30) = (SELECT TenKhoa 
											FROM inserted
											INNER JOIN KhoaKham
											ON KhoaKham.MaKhoa = inserted.MaKhoa)
			DECLARE @tenBV NVARCHAR(30) = (SELECT TenBV
										    FROM BenhVien 
											INNER JOIN KhoaKham
											ON BenhVien.MaBV = KhoaKham.MaBV
											WHERE KhoaKham.TenKhoa = @tenKhoa)
			DECLARE @notification NVARCHAR(100)
			SET @notification = N'Không thể thêm vào bệnh viện: ' + @tenBV + N' của khoa: ' + @tenKhoa
			RAISERROR(@notification, 16, 1)
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			UPDATE KhoaKham 
			SET SoBenhNhan = SoBenhNhan + 1
			WHERE KhoaKham.MaKhoa = (SELECT MaKhoa from inserted)
		END
END

--thực thi
--THÀNH CÔNG
INSERT INTO BenhNhan VALUES 
('BN06', N'Bệnh nhân 6', '2020-05-16',  N'Nữ', 4, 'K02')
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan
--THẤT BẠI
INSERT INTO BenhNhan VALUES 
('BN07', N'Bệnh nhân 7', '2020-05-16',  N'Nữ', 4, 'K03')
SELECT * FROM KhoaKham
SELECT * FROM BenhNhan

