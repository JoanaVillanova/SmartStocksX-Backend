USE [SmartStocksX]
GO
/****** Object:  DatabaseRole [Employer]    Script Date: 4/22/2025 3:04:31 PM ******/
CREATE ROLE [Employer]
GO
/****** Object:  DatabaseRole [Manager]    Script Date: 4/22/2025 3:04:31 PM ******/
CREATE ROLE [Manager]
GO
/****** Object:  DatabaseRole [Owner]    Script Date: 4/22/2025 3:04:31 PM ******/
CREATE ROLE [Owner]
GO
/****** Object:  Table [dbo].[product_count_trend]    Script Date: 4/22/2025 3:04:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[product_count_trend](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[total_products] [int] NULL,
	[recorded_at] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Products]    Script Date: 4/22/2025 3:04:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[ProductName] [varchar](150) NOT NULL,
	[Category] [varchar](100) NULL,
	[Brand] [varchar](100) NULL,
	[Quantity] [int] NULL,
	[Threshold] [int] NULL,
	[StockStatus] [varchar](50) NULL,
	[SupplierID] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SupplierDetails]    Script Date: 4/22/2025 3:04:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SupplierDetails](
	[SupplierDetailsID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[SupplierID] [int] NULL,
	[ProductID] [int] NULL,
	[CreatedAt] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[SupplierDetailsID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Suppliers]    Script Date: 4/22/2025 3:04:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Suppliers](
	[SupplierID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
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
/****** Object:  Table [dbo].[Users]    Script Date: 4/22/2025 3:04:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[UserID] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Username] [varchar](100) NOT NULL,
	[Email] [varchar](255) NOT NULL,
	[Password] [varchar](255) NOT NULL,
	[Role] [varchar](50) NOT NULL,
	[CreatedAt] [datetime] NULL,
	[Status] [varchar](50) NOT NULL,
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
ALTER TABLE [dbo].[product_count_trend] ADD  DEFAULT (getdate()) FOR [recorded_at]
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
ALTER TABLE [dbo].[Users] ADD  DEFAULT ('Active') FOR [Status]
GO
ALTER TABLE [dbo].[SupplierDetails]  WITH CHECK ADD FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[SupplierDetails]  WITH CHECK ADD FOREIGN KEY([SupplierID])
REFERENCES [dbo].[Suppliers] ([SupplierID])
GO
/****** Object:  StoredProcedure [dbo].[AddProduct]    Script Date: 4/22/2025 3:04:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddProduct]
    @ProductName VARCHAR(100),
    @Category VARCHAR(100),
    @Brand VARCHAR(100),
    @Quantity INT,
    @Threshold INT,
    @SupplierID INT  -- Include SupplierID here
AS
BEGIN
    INSERT INTO Products (ProductName, Category, Brand, Quantity, Threshold, SupplierID)
    VALUES (@ProductName, @Category, @Brand, @Quantity, @Threshold, @SupplierID)
END
GO
/****** Object:  StoredProcedure [dbo].[AddProductWithSupplier]    Script Date: 4/22/2025 3:04:32 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[AddProductWithSupplier]
    @ProductName VARCHAR(150),
    @Category VARCHAR(100),
    @Brand VARCHAR(100),
    @Quantity INT,
    @Threshold INT,
    @SupplierName VARCHAR(150)  -- We use supplier name here
AS
BEGIN
    DECLARE @StockStatus VARCHAR(50)
    DECLARE @ProductID INT
    DECLARE @SupplierID INT

    -- Determine stock status
    IF @Quantity = 0 AND @Threshold = 0
        SET @StockStatus = 'Out of Stock'
    ELSE IF @Quantity <= @Threshold
        SET @StockStatus = 'Low Stock'
    ELSE
        SET @StockStatus = 'In Stock'

    -- Insert into Products
    INSERT INTO Products (ProductName, Category, Brand, Quantity, Threshold, StockStatus)
    VALUES (@ProductName, @Category, @Brand, @Quantity, @Threshold, @StockStatus)

    -- Get the newly inserted ProductID
    SET @ProductID = SCOPE_IDENTITY()

    -- Get the SupplierID from name
    SELECT @SupplierID = SupplierID FROM Suppliers WHERE Name = @SupplierName

    -- Insert into SupplierDetails
    IF @SupplierID IS NOT NULL
    BEGIN
        INSERT INTO SupplierDetails (SupplierID, ProductID)
        VALUES (@SupplierID, @ProductID)
    END
    ELSE
    BEGIN
        PRINT '❌ Supplier not found. No record added to SupplierDetails.'
    END
END;
GO
