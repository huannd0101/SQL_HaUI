CREATE DATABASE QLSV
GO

USE QLSV
GO

CREATE TABLE Khoa (
	MaKhoa CHAR(3) PRIMARY KEY, 
	TenKhoa NVARCHAR(30) NOT NULL, 
	DiaChi NVARCHAR(30) NOT NULL, 
	SoDT CHAR(15) NOT NULL, 
	Email CHAR(30) NOT NULL
)

GO
CREATE TABLE Lop (
	MaLop CHAR(3) PRIMARY KEY, 
	TenLop NVARCHAR(30) NOT NULL,
	SiSo INT NOT NULL,
	MaKhoa CHAR(3), 
	CONSTRAINT fk_lop_khoa FOREIGN KEY(MaKhoa) REFERENCES Khoa(MaKhoa)
)

GO
CREATE TABLE SinhVien (
	MaSV CHAR(4) PRIMARY KEY, 
	HoTen NVARCHAR(30) NOT NULL,
	NgaySinh DATE  NOT NULL,
	GioiTinh NVARCHAR(15) NOT NULL,
	MaLop CHAR(3), 
	CONSTRAINT fk_sinhVien_lop FOREIGN KEY (MaLop) REFERENCES Lop(MaLop)
)

GO
INSERT INTO Khoa (MaKhoa, TenKhoa, DiaChi, SoDT, Email)
VALUES('K01', N'CNTT', N'Cơ Sở Minh Khai', '0123456789', 'khoacntt@mail.com')
INSERT INTO Khoa (MaKhoa, TenKhoa, DiaChi, SoDT, Email)
VALUES('K02', N'Điện Tử', N'Cơ Sở Tây Tựu', '0123456788', 'khoadientu@mail.com')
INSERT INTO Khoa (MaKhoa, TenKhoa, DiaChi, SoDT, Email)
VALUES('K03', N'Kế toán', N'Cơ Sở Minh Khai', '0123456787', 'khoaketoan@mail.com')

GO
INSERT INTO Lop (MaLop, TenLop, SiSo, MaKhoa)
VALUES ('L01', N'CNTT05', 81, 'K01')
INSERT INTO Lop (MaLop, TenLop, SiSo, MaKhoa)
VALUES ('L02', N'DienTu01', 60, 'K02')
INSERT INTO Lop (MaLop, TenLop, SiSo, MaKhoa)
VALUES ('L03', N'KeToan02', 65, 'K03')

GO
INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, MaLop)
VALUES ('SV01', N'Đào Thu Phương', '2000-01-01', N'Nữ', 'L01')
INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, MaLop)
VALUES ('SV02', N'Nguyễn Đinh Huân', '2001-01-01', N'Nam', 'L01')
INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, MaLop)
VALUES ('SV03', N'Nguyễn Thị A', '2002-01-01', N'Nữ', 'L02')
INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, MaLop)
VALUES ('SV04', N'Trần Văn A', '2003-01-01', N'Nam', 'L02')
INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, MaLop)
VALUES ('SV05', N'Nguyễn Thị B', '2004-01-01', N'Nữ', 'L03')

--xem dữ liệu
SELECT * FROM Khoa
SELECT * FROM Lop
SELECT * FROM SinhVien

--Câu 2:
GO
CREATE FUNCTION fn_cau2 (@tenKhoa NVARCHAR(30))
RETURNS @table TABLE(MaSV CHAR(4), HoTen NVARCHAR(30), Tuoi INT)
AS
BEGIN
	INSERT INTO @table
	SELECT MaSV, HoTen, (YEAR(GETDATE()) - YEAR(NgaySinh))
	FROM SinhVien INNER JOIN Lop
	ON SinhVien.MaLop = Lop.MaLop
	INNER JOIN Khoa
	ON Lop.MaKhoa = Khoa.MaKhoa
	WHERE TenKhoa = @tenKhoa
	RETURN 
END
--thực thi
SELECT * FROM dbo.fn_cau2 (N'CNTT')

--Câu 3:
GO
CREATE PROC p_cau3 (@tuTuoi INT, @denTuoi INT, @tenLop NVARCHAR(30))
AS
BEGIN
	SELECT MaSV, HoTen, NgaySinh, TenLop, TenKhoa, (YEAR(GETDATE()) - YEAR(NgaySinh)) AS N'Ngày Sinh'
	FROM Khoa INNER JOIN Lop ON Khoa.MaKhoa = Lop.MaKhoa
				INNER JOIN SinhVien ON Lop.MaLop = SinhVien.MaLop
	WHERE (YEAR(GETDATE()) - YEAR(NgaySinh)) BETWEEN @tuTuoi AND @denTuoi
			AND TenLop = @tenLop
END

--Thực thi
EXEC p_cau3 21, 21, N'CNTT05'

--Câu 4
GO
CREATE TRIGGER tg_cau4 
ON SinhVien
FOR INSERT
AS
BEGIN
	DECLARE @maLop CHAR(3) = (SELECT MaLop FROM inserted)
	DECLARE @maSV CHAR(4) = (SELECT MaSV FROM inserted)
	DECLARE @siSo INT = (SELECT SiSo FROM Lop WHERE MaLop = @maLop)
	IF(@siSo > 80)
		BEGIN
			RAISERROR(N'Không thể thêm', 16, 1)
			ROLLBACK TRAN
		END
	ELSE 
		BEGIN
			UPDATE Lop
			SET SiSo = SiSo + 1
			WHERE MaLop = @maLop
		END
END

--thực thi
--không thành công
INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, MaLop)
VALUES ('SV06', N'Nguyễn Thị Tý', '2000', N'Nữ', 'L01')
SELECT * FROM Lop
SELECT * FROM SinhVien
--thành công
INSERT INTO SinhVien (MaSV, HoTen, NgaySinh, GioiTinh, MaLop)
VALUES ('SV06', N'Nguyễn Thị Tý', '2000', N'Nữ', 'L02')
SELECT * FROM Lop
SELECT * FROM SinhVien