USE master
GO

-- tạo sơ sở dữ liệu 
CREATE DATABASE QLThuoc 
GO

USE QLThuoc 
GO
--tạo bảng Thuoc
CREATE TABLE Thuoc (
	MaThuoc CHAR(3) PRIMARY KEY, 
	TenThuoc NVARCHAR(30) NOT NULL, 
	SoLuong INT NOT NULL, 
	DonGia MONEY NOT NULL,
	NhaSX NVARCHAR(30)  NOT NULL
)
--tạo bảng BenhNhan
CREATE TABLE BenhNhan (
	MaBN CHAR(4) PRIMARY KEY, 
	TenBN NVARCHAR(30) NOT NULL,
	GioiTinh NVARCHAR(15) NOT NULL
)
--tạo bảng DonThuoc
CREATE TABLE DonThuoc (
	MaDon CHAR(5), 
	MaThuoc CHAR(3), 
	SoLuongBan INT NOT NULL, 
	NgayBan DATE, 
	MaBN CHAR(4), 
	PRIMARY KEY(MaDon, MaThuoc), 
	CONSTRAINT fk_donThuoc_benhnhan FOREIGN KEY(MaBN) REFERENCES BenhNhan(MaBN),
	CONSTRAINT fk_donThuoc_thuoc FOREIGN KEY(MaThuoc) REFERENCES Thuoc(MaThuoc)
)
GO

-- thêm dữ liệu cho bảng Thuoc
INSERT INTO Thuoc (MaThuoc, TenThuoc, SoLuong, DonGia, NhaSX)
VALUES('T01', N'Thuốc an thần', 20, 200000, N'Nhà sản xuất A')
INSERT INTO Thuoc (MaThuoc, TenThuoc, SoLuong, DonGia, NhaSX)
VALUES('T02', N'Thuốc dạ dày', 30, 300000, N'Nhà sản xuất B')
INSERT INTO Thuoc (MaThuoc, TenThuoc, SoLuong, DonGia, NhaSX)
VALUES('T03', N'Thuốc đau đầu', 40, 400000, N'Nhà sản xuất C')

-- thêm dữ liệu cho bảng BenhNhan
INSERT INTO BenhNhan (MaBN, TenBN, GioiTinh)
VALUES ('BN01', N'Đào Thu Phương', N'Nữ')
INSERT INTO BenhNhan (MaBN, TenBN, GioiTinh)
VALUES ('BN02', N'Trần Khắc Bình Dương', N'Nam')
INSERT INTO BenhNhan (MaBN, TenBN, GioiTinh)
VALUES ('BN03', N'Nguyễn Đình Huân', N'Nam')
-- thêm dữ liệu cho bảng DonThuoc
INSERT INTO DonThuoc (MaDon, MaThuoc, SoLuongBan, NgayBan, MaBN)
VALUES ('DT01', 'T01', 4, '2021-01-01', 'BN01')
INSERT INTO DonThuoc (MaDon, MaThuoc, SoLuongBan, NgayBan, MaBN)
VALUES ('DT02', 'T03', 5, '2021-01-02', 'BN01')
INSERT INTO DonThuoc (MaDon, MaThuoc, SoLuongBan, NgayBan, MaBN)
VALUES ('DT03', 'T01', 6, '2021-01-03', 'BN02')
INSERT INTO DonThuoc (MaDon, MaThuoc, SoLuongBan, NgayBan, MaBN)
VALUES ('DT04', 'T02', 7, '2021-01-04', 'BN02')
INSERT INTO DonThuoc (MaDon, MaThuoc, SoLuongBan, NgayBan, MaBN)
VALUES ('DT05', 'T01', 8, '2021-01-05', 'BN03')

--Xem dữ liệu các bảng 
SELECT * FROM Thuoc
SELECT * FROM BenhNhan
SELECT * FROM DonThuoc

--Câu 2:
GO
CREATE FUNCTION fn_cau2(@nhaSX NVARCHAR(30), @ngayBan DATE)
RETURNS @table TABLE(MaBN CHAR(4), TenBN NVARCHAR(30), GioiTinh NVARCHAR(15), MaThuoc CHAR(3), TenThuoc NVARCHAR(30), SoLuong INT, DonGia MONEY)
AS
BEGIN
	INSERT INTO @table
	SELECT BenhNhan.MaBN, TenBN, GioiTinh, Thuoc.MaThuoc, TenThuoc, SoLuong, DonGia
	FROM Thuoc INNER JOIN DonThuoc ON Thuoc.MaThuoc = DonThuoc.MaThuoc
				INNER JOIN BenhNhan ON BenhNhan.MaBN = DonThuoc.MaBN
	WHERE NgayBan = @ngayBan AND NhaSX = @nhaSX
	RETURN
END

--Thực thi:
SELECT * FROM dbo.fn_cau2 (N'Nhà sản xuất A', '2021-01-01')

--Câu 3:
GO
CREATE PROC p_cau3 (@maDon CHAR(4), @tenThuoc NVARCHAR(30), @soLuongBan INT, @ngayBan DATE, @maBN CHAR(4))
AS
BEGIN
	IF(NOT EXISTS(SELECT * FROM Thuoc WHERE TenThuoc = @tenThuoc))
		BEGIN
			PRINT N'Tên thuốc không tồn tại'
			RETURN
		END
	ELSE 
		BEGIN
			DECLARE @maThuoc CHAR(3) = (
				SELECT MaThuoc
				FROM Thuoc
				WHERE TenThuoc = @tenThuoc
			)
			INSERT INTO DonThuoc (MaDon, MaThuoc, SoLuongBan, NgayBan, MaBN)
			VALUES (@maDon, @maThuoc, @soLuongBan, @ngayBan, @maBN)
		END
END

--Thực thi
--thêm không thành công(không có tên: Thuốc đau bụng)
EXEC p_cau3 'DT06', N'Thuốc đau bụng', 8, '2021-01-05', 'BN03'
SELECT * FROM DonThuoc
--thêm thành công
EXEC p_cau3 'DT06', N'Thuốc an thần', 8, '2021-01-05', 'BN03'
SELECT * FROM DonThuoc

GO
--Câu 4:

CREATE TRIGGER tg_cau4
ON DonThuoc
FOR INSERT
AS
BEGIN
	DECLARE @SoLuongBan INT = (
			SELECT SoLuongBan
			FROM inserted
		)

	DECLARE @SoLuong INT = (
		SELECT SoLuong
		FROM Thuoc INNER JOIN inserted
		ON Thuoc.MaThuoc = inserted.MaThuoc
	)

	IF(@SoLuong < @SoLuongBan)
		BEGIN
			RAISERROR(N'Không đủ số lượng để bán hàng', 16, 1)
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			UPDATE Thuoc
			SET SoLuong = SoLuong - @SoLuongBan
			FROM Thuoc INNER JOIN inserted
			ON Thuoc.MaThuoc = inserted.MaThuoc
		END
END
GO
--Thực thi
--không thành công(số lượng không đủ)
INSERT INTO DonThuoc (MaDon, MaThuoc, SoLuongBan, NgayBan, MaBN)
VALUES ('DT08', 'T02', 10000, '2021-01-01', 'BN02')
SELECT * FROM Thuoc
SELECT * FROM DonThuoc

--thành công(số lượng đủ)
INSERT INTO DonThuoc (MaDon, MaThuoc, SoLuongBan, NgayBan, MaBN)
VALUES ('DT07', 'T03', 2, '2021-01-01', 'BN01')
SELECT * FROM Thuoc
SELECT * FROM DonThuoc
