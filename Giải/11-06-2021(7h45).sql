USE master
GO

CREATE DATABASE QLSinhVien 
GO

USE QLSinhVien 
GO

CREATE TABLE Khoa (
	MaKhoa CHAR(5) PRIMARY KEY, 
	TenKhoa NVARCHAR(30) NOT NULL
)

CREATE TABLE Lop(
	MaLop CHAR(5) PRIMARY KEY,
	TenLop NVARCHAR(30) NOT NULL,
	SiSo INT NOT NULL,
	MaKhoa CHAR(5), 
	CONSTRAINT fk_lop_khoa FOREIGN KEY(MaKhoa) REFERENCES Khoa(MaKhoa)
)

CREATE TABLE SinhVien(
	MaSV CHAR(5) PRIMARY KEY, 
	HoTen NVARCHAR(30) NOT NULL, 
	NgaySinh DATE NOT NULL, 
	GioiTinh NVARCHAR(15) NOT NULL, 
	MaLop CHAR(5), 
	CONSTRAINT fk_sinhVien_Lop FOREIGN KEY(MaLop) REFERENCES Lop(MaLop)
)

INSERT INTO Khoa VALUES
('K01', N'Khoa CNTT'),
('K02', N'Khoa Kế Toán'),
('K03', N'Khoa Điện')

INSERT INTO Lop VALUES
('L01', N'CNTT01', 81, 'K01'),
('L02', N'CNTT02', 60, 'K01'),
('L03', N'Kế toán', 60, 'K02')

INSERT INTO SinhVien VALUES
('SV01', N'Nguyễn Đình Huân', '2001-01-01', N'Nam', 'L01'),
('SV02', N'Trần Khắc Bình Dương', '2002-01-01', N'Nam', 'L01'),
('SV03', N'Phạm Ánh Trường', '2001-02-02', N'Nữ', 'L02'),
('SV04', N'Nguyễn Lương Hùng', '2001-03-03', N'Nam', 'L02'),
('SV05', N'Đào Thu Phương', '2003-01-01', N'Nữ', 'L03')

--xem dữ liệu trong các bảng
SELECT * FROM Khoa
SELECT * FROM Lop
SELECT * FROM SinhVien

--Câu 2:
GO
CREATE FUNCTION fn_cau2(@tenKhoa NVARCHAR(30))
RETURNS @table TABLE(MaSV CHAR(5), HoTen NVARCHAR(30), Tuoi INT)
AS
BEGIN
	INSERT INTO @table
	SELECT MaSV, HoTen, YEAR(GETDATE()) - YEAR(NgaySinh)
	FROM Khoa INNER JOIN Lop
	ON Khoa.MaKhoa = Lop.MaKhoa
	INNER JOIN SinhVien
	ON Lop.MaLop = SinhVien.MaLop
	WHERE TenKhoa = @tenKhoa
	RETURN 
END

--Thực thi
SELECT * FROM dbo.fn_cau2 (N'Khoa CNTT')

--Câu 3:
GO
CREATE PROC p_cau3(@tuTuoi INT, @denTuoi INT)
AS
BEGIN
	SELECT MaSV, HoTen, NgaySinh, TenLop, TenKhoa, YEAR(GETDATE()) - YEAR(NgaySinh) AS N'Tuổi'
	FROM Khoa INNER JOIN Lop
	ON Khoa.MaKhoa = Lop.MaKhoa
	INNER JOIN SinhVien
	ON Lop.MaLop = SinhVien.MaLop
	WHERE (YEAR(GETDATE()) - YEAR(NgaySinh))  BETWEEN @tuTuoi AND @denTuoi
END

--Thực thi
EXEC p_cau3 20, 21

--Câu 4:
GO
CREATE TRIGGER tg_cau4 
ON SinhVien
FOR INSERT 
AS
BEGIN
	DECLARE @maLop CHAR(5)
	SELECT @maLop = (SELECT MaLop FROM inserted)

	DECLARE @siSo INT 
	SELECT @siSo = (
		SELECT SiSo
		FROM Lop
		WHERE MaLop = @maLop
	)

	IF(@siSo > 80)
		BEGIN
			RAISERROR(N'Si so lop > 80', 16, 1)
			ROLLBACK TRAN
		END
	ELSE
		BEGIN
			UPDATE Lop 
			SET SiSo = SiSo + 1
			WHERE MaLop = @maLop
		END
END

--Thực thi
--Thêm mới thất bại(lớp: L01 sĩ số hiện tại là 81)
INSERT INTO SinhVien VALUES ('SV06', N'Đào Thu Phương', '2000-05-05', N'Nữ', 'L01')
SELECT * FROM SinhVien
SELECT * FROM Lop
--Thêm mới thành công(lớp: L02 sĩ số hiện tại là 60)
INSERT INTO SinhVien VALUES ('SV06', N'Đào Thu Phương', '2000-05-05', N'Nữ', 'L02')
SELECT * FROM SinhVien
SELECT * FROM Lop
