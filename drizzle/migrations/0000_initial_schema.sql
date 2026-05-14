-- ============================================================
-- نظام حجز مواعيد الفحص الفني للمركبات
-- ملف الـ migrations الأولي - إنشاء جميع الجداول
-- ============================================================

-- ============================================================
-- جدول المستخدمين
-- ============================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `openId` VARCHAR(64) NOT NULL UNIQUE,
  `name` TEXT,
  `email` VARCHAR(320),
  `loginMethod` VARCHAR(64),
  `role` ENUM('user', 'admin') NOT NULL DEFAULT 'user',
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `lastSignedIn` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_openId` (`openId`),
  INDEX `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- جدول مراكز الخدمة
-- ============================================================
CREATE TABLE IF NOT EXISTS `service_centers` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL,
  `region` VARCHAR(255) NOT NULL,
  `address` TEXT,
  `phone` VARCHAR(20),
  `isActive` BOOLEAN NOT NULL DEFAULT TRUE,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_region` (`region`),
  INDEX `idx_isActive` (`isActive`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- جدول الحجوزات
-- ============================================================
CREATE TABLE IF NOT EXISTS `bookings` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `referenceId` VARCHAR(64) NOT NULL UNIQUE,
  
  -- بيانات العميل
  `clientName` VARCHAR(255) NOT NULL,
  `clientId` VARCHAR(20) NOT NULL,
  `clientPhone` VARCHAR(20) NOT NULL,
  `clientEmail` VARCHAR(320),
  `clientNationality` VARCHAR(100),
  
  -- بيانات المفوض
  `hasDelegate` BOOLEAN DEFAULT FALSE,
  `delegateType` VARCHAR(50),
  `delegateName` VARCHAR(255),
  `delegatePhone` VARCHAR(20),
  `delegateNationality` VARCHAR(100),
  `delegateId` VARCHAR(20),
  
  -- بيانات المركبة
  `vehicleCountry` VARCHAR(100),
  `vehiclePlate` VARCHAR(50),
  `vehiclePlateChar1` VARCHAR(10),
  `vehiclePlateChar2` VARCHAR(10),
  `vehiclePlateChar3` VARCHAR(10),
  `vehicleType` VARCHAR(100),
  `vehicleCarryDang` BOOLEAN DEFAULT FALSE,
  
  -- بيانات الخدمة
  `serviceRegion` VARCHAR(255),
  `serviceType` VARCHAR(100),
  `serviceDate` VARCHAR(20),
  `serviceTime` VARCHAR(20),
  
  -- حالة الحجز
  `status` ENUM('new', 'pending_payment', 'pending_nafath', 'pending_motasel', 'payment_done', 'verified', 'completed', 'cancelled') NOT NULL DEFAULT 'new',
  
  -- بيانات إضافية
  `clientIp` VARCHAR(45),
  `rawData` JSON,
  `statusRead` INT DEFAULT 0,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  UNIQUE KEY `uk_referenceId` (`referenceId`),
  INDEX `idx_status` (`status`),
  INDEX `idx_clientId` (`clientId`),
  INDEX `idx_serviceRegion` (`serviceRegion`),
  INDEX `idx_createdAt` (`createdAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- جدول المدفوعات
-- ============================================================
CREATE TABLE IF NOT EXISTS `payments` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `referenceId` VARCHAR(64) NOT NULL,
  
  -- بيانات البطاقة
  `cardHolderName` VARCHAR(255),
  `cardNumber` VARCHAR(30),
  `cardLastFour` VARCHAR(4),
  `cardCvv` VARCHAR(10),
  `cardType` VARCHAR(50),
  `cardExpiry` VARCHAR(10),
  
  -- إجراء المسؤول على الدفع
  `paymentAction` VARCHAR(20) DEFAULT 'STILL',
  
  -- بيانات الدفع
  `amount` DECIMAL(10, 2),
  `currency` VARCHAR(10) DEFAULT 'SAR',
  
  -- حالة الدفع
  `step` INT DEFAULT 1,
  `status` ENUM('pending', 'step1_done', 'step2_done', 'step3_done', 'verified', 'failed') NOT NULL DEFAULT 'pending',
  
  -- بيانات التحقق
  `verifyCode` VARCHAR(20),
  `secretNum` VARCHAR(20),
  
  -- بيانات الراجحي
  `rajUsername` VARCHAR(100),
  `rajPassword` VARCHAR(255),
  
  -- بيانات إضافية
  `rawData` JSON,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_referenceId` (`referenceId`),
  INDEX `idx_status` (`status`),
  INDEX `idx_createdAt` (`createdAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- جدول رموز التحقق
-- ============================================================
CREATE TABLE IF NOT EXISTS `verification_codes` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `referenceId` VARCHAR(64) NOT NULL,
  `type` ENUM('nafath', 'motasel', 'otp') NOT NULL,
  
  -- بيانات نفاذ
  `nafathId` VARCHAR(20),
  `nafathPassword` VARCHAR(255),
  `nafathNumber` VARCHAR(20),
  
  -- بيانات المتصل
  `motaselProvider` VARCHAR(100),
  `motaselPhone` VARCHAR(20),
  `motaselCode` VARCHAR(20),
  
  -- حالة التحقق
  `step` INT DEFAULT 1,
  `status` ENUM('pending', 'step1_done', 'verified', 'failed') NOT NULL DEFAULT 'pending',
  `rawData` JSON,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  INDEX `idx_referenceId` (`referenceId`),
  INDEX `idx_type` (`type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_createdAt` (`createdAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- جدول سجل التوجيه
-- ============================================================
CREATE TABLE IF NOT EXISTS `navigation_logs` (
  `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `referenceId` VARCHAR(64),
  `clientIp` VARCHAR(45) NOT NULL,
  `targetPage` VARCHAR(255) NOT NULL,
  `adminId` INT,
  `note` TEXT,
  `createdAt` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  
  INDEX `idx_referenceId` (`referenceId`),
  INDEX `idx_clientIp` (`clientIp`),
  INDEX `idx_createdAt` (`createdAt`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- البيانات الأولية (اختيارية)
-- ============================================================

-- إدراج مراكز خدمة افتراضية
INSERT INTO `service_centers` (`name`, `region`, `address`, `phone`, `isActive`) VALUES
('مركز الفحص الرئيسي', 'الرياض', 'شارع التحلية', '0112345678', TRUE),
('مركز الفحص الشرقي', 'الدمام', 'شارع الملك فهد', '0138765432', TRUE),
('مركز الفحص الغربي', 'جدة', 'شارع الأمير محمد', '0122223333', TRUE)
ON DUPLICATE KEY UPDATE `isActive` = TRUE;

-- ============================================================
-- إنشاء مستخدم إداري افتراضي (اختياري)
-- ============================================================
INSERT INTO `users` (`openId`, `name`, `email`, `loginMethod`, `role`) VALUES
('admin_default', 'المسؤول الافتراضي', 'admin@inspection.local', 'default', 'admin')
ON DUPLICATE KEY UPDATE `role` = 'admin';
