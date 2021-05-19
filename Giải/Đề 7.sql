--Ð? 7
USE master
GO
DROP DATABASE QLSinhVien
GO

CREATE DATABASE QLSinhVien
GO

USE QLSinhVien
GO

CREATE TABLE Khoa (
	MaKhoa CHAR(5) PRIMARY KEY, 
	TenKhoa NVARCHAR(30), 
	SoDienThoai CHAR(20)
)

CREATE TABLE Lop (
	MaLop CHAR(5) PRIMARY KEY, 
	TenLop NVARCHAR(30), 
	SiSo INT, 
	MaKhoa CHAR(5) FOREIGN KEY(MaKhoa) REFERENCES Khoa(MaKhoa)
)

CREATE TABLE SinhVien (
	MaSV CHAR(5) PRIMARY KEY, 
	HoTen NVARCHAR(30), 
	GioiTinh NVARCHAR(20), 
	NgaySinh DATE, 
	MaLop CHAR(5) FOREIGN KEY(MaLop) REFERENCES Lop(MaLop)
)

INSERT INTO Khoa VALUES
('K01', N'Khoa 1', '0375417807'),
('K02', N'Khoa 2', '0375417808'),
('K03', N'Khoa 3', '0375417809')

INSERT INTO Lop VALUES 
('L01', N'A1', 44, 'K01'),
('L02', N'A2', 65, 'K02'),
('L03', N'A3', 67, 'K02')

INSERT INTO Sinhvien VALUES 
('SV01', N'Nguyen Thi Ty', N'Nu', '2000/03/13', 'L01'),
('SV02', N'Hoang Van Thai', N'Nam', '1999/03/13', 'L01'),
('SV03', N'Nguyen Thi Ngoc', N'Nu', '2001/05/13', 'L01'),
('SV04', N'Hoang Thi Nam', N'Nu', '2000/03/13', 'L02'),
('SV05', N'Le Anh Tuyet', N'Nu', '1997/05/25', 'L03')

SELECT * FROM Khoa
SELECT * FROM Lop
SELECT * FROM SinhVien

--Câu 2:tạo hàm
GO
CREATE FUNCTION fn_cau2 (@tenKhoa NVARCHAR(30))
RETURNS @table TABLE(MaLop CHAR(5), TenLop NVARCHAR(30), SiSo INT)
AS
BEGIN
	INSERT INTO @table
	SELECT MaLop, TenLop, SiSo
	FROM Khoa INNER JOIN Lop
	ON Khoa.MaKhoa = Lop.MaKhoa
	WHERE TenKhoa = @tenKhoa

	RETURN
END

--Thực thi
GO
SELECT * FROM dbo.fn_cau2 (N'Khoa 1')

--CÂU 3
GO
CREATE PROC p_cau3 (@maSV CHAR(5), @hoTen NVARCHAR(30), @ngaySinh DATE, @gioiTinh NVARCHAR(20), @tenLOP NVARCHAR(30))
AS
BEGIN
	--KTRA TÊN L?P
	IF(NOT EXISTS(SELECT * FROM Lop WHERE TenLop = @tenLOP))
		BEGIN
			PRINT N'Không có lớp này :v'
			RETURN 
		END

	DECLARE @maLop CHAR(5) = (
		SELECT MaLop
		FROM Lop
		WHERE TenLop = @tenLOP
	)

	INSERT INTO SinhVien VALUES (@maSV, @hoTen, @gioiTinh, @ngaySinh, @maLop)
END

--TH?C THI
--THÊM THÀNH CÔNG
EXEC p_cau3 'SV06', N'Huân đep trai', '2001-01-01', N'Nam', 'A1'
SELECT * FROM SinhVien
--THÊM TH?T B?I: TÊN L?P K CÓ
EXEC p_cau3 'SV07', N'Huân đẹp trai', '2001-01-01', N'Nam', 'A7'
SELECT * FROM SinhVien

--Câu 4:
CREATE TRIGGER tg_cau4 
ON SinhVien
FOR UPDATE
AS
BEGIN
	DECLARE @siSoLiopMoi INT = (
		SELECT SiSo
		FROM inserted INNER JOIN Lop 
		ON inserted.MaLop = Lop.MaLop
	)
	IF(@siSoLiopMoi >= 80)
		BEGIN
			RAISERROR(N'Lớp nhiều học sinh, không thể thêm', 16, 1)
			ROLLBACK TRAN
		END
	ELSE 
		BEGIN
			UPDATE Lop
			SET SiSo = SiSo + 1
			WHERE MaLop = (SELECT MaLop FROM inserted)

			UPDATE Lop
			SET SiSo = SiSo - 1
			WHERE MaLop = (SELECT MaLop FROM deleted)
		END
END

--TH?C THI
