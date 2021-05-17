--Đề 3
CREATE DATABASE QLSinhVien
GO

USE QLSinhVien
GO

CREATE TABLE Khoa (
	MaKhoa CHAR(5) PRIMARY KEY, 
	TenKhoa NVARCHAR(30)
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
	NgaySinh DATE, 
	GioiTinh BIT, 
	MaLop CHAR(5) FOREIGN KEY(MaLop) REFERENCES Lop(MaLop)
)

INSERT INTO Khoa VALUES
('K01', N'Khoa 1'), 
('K02', N'Khoa 2'), 
('K03', N'Khoa 3')

INSERT INTO Lop VALUES
('L01', N'Lớp 1', 30, 'K01'), 
('L02', N'Lớp 2', 40, 'K01'), 
('L03', N'Lớp 3', 90, 'K02')

INSERT INTO SinhVien VALUES
('SV01', N'Sinh viên 1', '2001-01-01', 0, 'L01'),
('SV02', N'Sinh viên 2', '2001-03-01', 1, 'L01'),
('SV03', N'Sinh viên 3', '2001-07-05', 0, 'L02'),
('SV04', N'Sinh viên 4', '2001-01-03', 1, 'L02'),
('SV05', N'Sinh viên 5', '2000-11-01', 0, 'L03')

SELECT * FROM Khoa
SELECT * FROM Lop
SELECT * FROM SinhVien

--Câu 2: tạo hàm
ALTER FUNCTION fn_cau2 (@tenKhoa NVARCHAR(30))
RETURNS @bang TABLE(MaSV CHAR(5),
					HoTen NVARCHAR(30),
					NgaySinh DATE, 
					Tuoi DATE
					)
AS
BEGIN
	INSERT INTO @bang
	SELECT MaSV, HoTen, NgaySinh, FORMAT(NgaySinh,'dd/MM/yyyy') AS Tuoi
	FROM Khoa INNER JOIN Lop 
	ON Khoa.MaKhoa = Lop.MaKhoa
	INNER JOIN SinhVien
	ON Lop.MaLop = SinhVien.MaLop
	WHERE TenKhoa = @tenKhoa AND YEAR(NgaySinh) = (SELECT MAX(YEAR(NgaySinh))
													FROM SinhVien INNER JOIN Lop
													ON SinhVien.MaLop = Lop.MaLop
													INNER JOIN Khoa
													ON Khoa.MaKhoa = Lop.MaKhoa
													WHERE TenKhoa = @tenKhoa)
	RETURN
END

--thực thi
SELECT * FROM dbo.fn_cau2 (N'Khoa 1')

SELECT * FROM Khoa
SELECT * FROM Lop
SELECT * FROM SinhVien

--Câu 3: tạo proc
GO
CREATE PROC p_cau3 (@tuTuoi INT, @denTuoi INT)
AS
BEGIN
	SELECT MaSV, HoTen, TenKhoa, YEAR(GETDATE()) - YEAR(NgaySinh) AS N'Tuổi'
	FROM SinhVien INNER JOIN Lop
	ON SinhVien.MaLop = Lop.MaLop 
	INNER JOIN Khoa
	ON Lop.MaKhoa = Khoa.MaKhoa
	WHERE YEAR(GETDATE()) - YEAR(NgaySinh) BETWEEN @tuTuoi AND @denTuoi
END

--thực thi
EXEC p_cau3 21, 21

--câu 4: tạo trigger
CREATE TRIGGER tg_cau4
ON SinhVien
FOR DELETE, INSERT
AS
BEGIN
	DECLARE @action CHAR(1)
	SET @action = (CASE WHEN EXISTS (SELECT * FROM inserted)
						THEN 'I' 
						WHEN EXISTS (SELECT * FROM deleted)
						THEN 'D'
						END)
	-- Xử lý xóa
	IF(@action = 'D')
		BEGIN
			UPDATE Lop 
			SET SiSo = SiSo - 1
			WHERE MaLop = (SELECT MaLop FROM deleted)
		END
	ELSE -- Xử lý chèn
		BEGIN
			DECLARE @siSo INT
			SET @siSo = (SELECT SiSo FROM Lop INNER JOIN inserted ON Lop.MaLop = inserted.MaLop)
			IF(@siSo > 80)
				BEGIN
					DECLARE @lop NVARCHAR(30)
					SET @lop = (SELECT TenLop FROM Lop INNER JOIN inserted ON Lop.MaLop = inserted.MaLop)
					
					DECLARE @notification NVARCHAR(100)
					SET @notification = N'Không thể thêm sinh viên vào lớp ' + @lop

					RAISERROR(@notification, 16, 1)
					ROLLBACK TRAN
				END
			ELSE 
				BEGIN
					UPDATE Lop 
					SET SiSo = SiSo + 1
					WHERE MaLop = (SELECT MaLop FROM inserted)
				END
		END
END

--thực thi
--insert thất bại
INSERT INTO SinhVien VALUES ('SV06', N'Sinh viên 6', '2000-11-01', 0, 'L03')
SELECT * FROM Lop
SELECT * FROM SinhVien
--insert thành công
INSERT INTO SinhVien VALUES ('SV06', N'Sinh viên 6', '2000-11-01', 0, 'L01')
SELECT * FROM Lop
SELECT * FROM SinhVien
--delete
DELETE SinhVien WHERE MaSV = 'SV01'
SELECT * FROM Lop
SELECT * FROM SinhVien

