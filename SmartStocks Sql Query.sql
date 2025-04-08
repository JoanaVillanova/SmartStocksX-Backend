USE [SmartStocksX]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 4/2/2025 8:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[ProductName] [varchar](150) NOT NULL,
	[Category] [varchar](100) NULL,
	[Brand] [varchar](100) NULL,
	[Quantity] [int] NULL,
	[Threshold] [int] NULL,
	[StockStatus] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SupplierDetails]    Script Date: 4/2/2025 8:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SupplierDetails](
	[SupplierDetailsID] [int] IDENTITY(1,1) NOT NULL,
	[SupplierID] [int] NULL,
	[ProductID] [int] NULL,
	[Price] [decimal](10, 2) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SupplierDetailsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Suppliers]    Script Date: 4/2/2025 8:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suppliers](
	[SupplierID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](150) NOT NULL,
	[Contact] [varchar](100) NULL,
	[Website] [varchar](255) NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SupplierID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Users]    Script Date: 4/2/2025 8:17:38 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT NULL,
	[Username] [varchar](100) NOT NULL,
	[Email] [varchar](255) NOT NULL,
	[Password] [varchar](255) NOT NULL,
	[Role] [varchar](50) NOT NULL,
	[CreatedAt] [datetime] NULL,
	[LastLogin] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [Quantity]
GO
ALTER TABLE [dbo].[Products] ADD  DEFAULT ((0)) FOR [Threshold]
GO
ALTER TABLE [dbo].[SupplierDetails] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Suppliers] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT (getdate()) FOR [CreatedAt]
GO
ALTER TABLE [dbo].[SupplierDetails]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[SupplierDetails]  WITH CHECK ADD FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])
GO

-- Trigger on INSERT
CREATE TRIGGER trg_SetStockStatus_OnInsert
ON Products
AFTER INSERT
AS
BEGIN
    UPDATE Products
    SET StockStatus =
        CASE 
            WHEN i.Quantity = 0 AND i.Threshold = 0 THEN 'Out of Stock'
            WHEN i.Quantity <= i.Threshold THEN 'Low Stock'
            ELSE 'In Stock'
        END
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END
GO

-- Trigger on UPDATE
CREATE TRIGGER trg_UpdateStockStatus_OnUpdate
ON Products
AFTER UPDATE
AS
BEGIN
    UPDATE Products
    SET StockStatus =
        CASE 
            WHEN i.Quantity = 0 AND i.Threshold = 0 THEN 'Out of Stock'
            WHEN i.Quantity <= i.Threshold THEN 'Low Stock'
            ELSE 'In Stock'
        END
    FROM Products p
    INNER JOIN inserted i ON p.ProductID = i.ProductID;
END
GO

-- Stored Procedures

USE SmartStocksX;
GO

CREATE PROCEDURE AddProduct
    @ProductName VARCHAR(150),
    @Category VARCHAR(100),
    @Brand VARCHAR(100),
    @Quantity INT,
    @Threshold INT
AS
BEGIN
    DECLARE @StockStatus VARCHAR(50)

    IF @Quantity = 0 AND @Threshold = 0
        SET @StockStatus = 'Out of Stock'
    ELSE IF @Quantity <= @Threshold
        SET @StockStatus = 'Low Stock'
    ELSE
        SET @StockStatus = 'In Stock'

    INSERT INTO Products (ProductName, Category, Brand, Quantity, Threshold, StockStatus)
    VALUES (@ProductName, @Category, @Brand, @Quantity, @Threshold, @StockStatus)
END;
GO

EXEC AddProduct 
    @ProductName = 'Test Boba',
    @Category = 'Boba',
    @Brand = 'BobaBlast',
    @Quantity = 3,
    @Threshold = 5;


select * from Products
