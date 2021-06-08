CREATE DATABASE	QLSinhVien2
GO

USE QLSinhVien2
GO

CREATE TABLE Khoa (
	MaKhoa char(5) PRIMARY KEY, 
	TenKhoa NVARCHAR(30), 
	NgayThanhLap DATE
)

CREATE TABLE Lop (
	MaLop CHAR(5) PRIMARY KEY, 
	TenLop NVARCHAR(30), 
	SiSo INT, 
	MaKhoa CHAR(5) FOREIGN KEY(MaKhoa) REFERENCES Khoa(MaKhoa)
)

CREATE TABLE SinhVien(
	MaSV CHAR(5) PRIMARY KEY, 
	HoTen NVARCHAR(30) NOT NULL, 
	NgaySinh DATE NOT NULL,
	MaLop CHAR(5),
	CONSTRAINT fk_Lop_SinhVien FOREIGN KEY(MaLop) REFERENCES Lop(MaLop)
)

INSERT INTO Khoa (MaKhoa, TenKhoa, NgayThanhLap)
VALUES ('K01', N'Khoa 1', '2020-01-01')
INSERT INTO Khoa (MaKhoa, TenKhoa, NgayThanhLap)
VALUES ('K02', N'Khoa 2', '2019-01-01')
INSERT INTO Khoa (MaKhoa, TenKhoa, NgayThanhLap)
VALUES ('K03', N'Khoa 3', '2018-01-01')

INSERT INTO Lop VALUES 
('L01', N'Lớp 1', 20, 'K01'),
('L02', N'Lớp 2', 3, 'K01'),
('L03', N'Lớp 3', 10, 'K02')

INSERT INTO SinhVien VALUES 
('SV01', N'Sinh viên 1', '2001-01-01', 'L01'),
('SV02', N'Sinh viên 2', '2001-01-02', 'L01'),
('SV03', N'Sinh viên 3', '2001-01-03', 'L02'),
('SV04', N'Sinh viên 4', '2001-01-04', 'L02'),
('SV05', N'Sinh viên 5', '2001-01-05', 'L03')

--Xem dữ liệu các bảng
SELECT * FROM Khoa
SELECT * FROM Lop
SELECT * FROM SinhVien

--Câu 2: 
GO
CREATE FUNCTION fn_cau2 (@tenLop NVARCHAR(30))
RETURNS @bang TABLE(MaSV CHAR(5), HoTen NVARCHAR(30), Tuoi INT, TenKhoa NVARCHAR(30))
AS
BEGIN
	INSERT INTO @bang
	SELECT MaSV, HoTen, (YEAR(GETDATE()) - YEAR(NgaySinh)), TenKhoa
	FROM SinhVien INNER JOIN Lop
	ON SinhVien.MaLop = Lop.MaLop
	INNER JOIN Khoa
	ON Khoa.MaKhoa = Lop.MaKhoa
	WHERE TenLop = @tenLop

	RETURN
END
--THỰC THI
SELECT * FROM fn_cau2 (N'Lớp 2')

--Câu 4:
DROP TRIGGER tg_cau4
GO
CREATE TRIGGER tg_cau4
ON SinhVien
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @maSV CHAR(5) = (SELECT MaSV FROM deleted)
	IF(NOT EXISTS(SELECT * FROM SinhVien WHERE MaSV = @maSV))
		BEGIN
			RAISERROR(N'Không có mã sinh viên này', 16, 1)
			ROLLBACK TRAN
		END
	ELSE 
		BEGIN
			DELETE FROM SinhVien
			WHERE MaSV = @maSV
			UPDATE Lop
			SET SiSo = SiSo - 1
			WHERE MaLop = (SELECT MaLop FROM deleted)
		END
END

--THỰC THI
--KHÔNG THÀNH CÔNG
DELETE SinhVien WHERE MaSV = 'SV06'
SELECT * FROM Lop
SELECT * FROM SinhVien
--THÀNH CÔNG
DELETE SinhVien WHERE MaSV = 'SV03'
SELECT * FROM Lop
SELECT * FROM SinhVien