-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-07-2025 a las 00:25:45
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `checklist_berilion`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `crear_visita_completa` (IN `p_id_sede` INT, IN `p_cedula_tecnico` VARCHAR(20), IN `p_fecha_visita` DATE, OUT `p_id_visita` INT)   BEGIN
    DECLARE v_id_tecnico INT;
    
    -- Obtener ID del técnico
    SELECT id INTO v_id_tecnico 
    FROM tecnicos 
    WHERE cedula = p_cedula_tecnico AND activo = TRUE;
    
    IF v_id_tecnico IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Técnico no encontrado o inactivo';
    END IF;
    
    -- Crear la visita
    INSERT INTO visitas (id_sede, id_tecnico, fecha_visita, estado)
    VALUES (p_id_sede, v_id_tecnico, p_fecha_visita, 'pendiente');
    
    SET p_id_visita = LAST_INSERT_ID();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `estadisticas_sede` (IN `p_id_sede` INT)   BEGIN
    SELECT 
        COUNT(*) as total_visitas,
        COUNT(CASE WHEN estado = 'completada' THEN 1 END) as visitas_completadas,
        MAX(fecha_visita) as ultima_visita,
        AVG(CASE WHEN er.servidor_dedicado THEN 1 ELSE 0 END) as porcentaje_servidor_dedicado
    FROM visitas v
    LEFT JOIN evaluacion_rack er ON v.id = er.id_visita
    WHERE v.id_sede = p_id_sede;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `archivos_adjuntos`
--

CREATE TABLE `archivos_adjuntos` (
  `id` int(11) NOT NULL,
  `id_visita` int(11) NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `ruta_archivo` varchar(500) NOT NULL,
  `tipo_archivo` varchar(50) DEFAULT NULL,
  `tamaño_kb` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `equipos`
--

CREATE TABLE `equipos` (
  `id` int(11) NOT NULL,
  `id_visita` int(11) NOT NULL,
  `tipo_equipo` enum('servidor','administrativo','caja') NOT NULL,
  `numero_equipo` int(11) NOT NULL,
  `procesador` varchar(100) DEFAULT NULL,
  `ram_gb` int(11) DEFAULT NULL,
  `modelo_ram` varchar(100) DEFAULT NULL,
  `disco_gb` int(11) DEFAULT NULL,
  `tipo_disco` enum('HDD','SSD','NVME') DEFAULT NULL,
  `sistema_operativo` varchar(50) DEFAULT NULL,
  `usuario_final` varchar(100) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evaluacion_informatica`
--

CREATE TABLE `evaluacion_informatica` (
  `id` int(11) NOT NULL,
  `id_visita` int(11) NOT NULL,
  `id_proveedor_internet` int(11) DEFAULT NULL,
  `posee_interbancario` tinyint(1) DEFAULT 0,
  `posee_switch_cajas` tinyint(1) DEFAULT 0,
  `cantidad_impresoras_fiscal` int(11) DEFAULT 0,
  `impresora_local` tinyint(1) DEFAULT 0,
  `biometrico` tinyint(1) DEFAULT 0,
  `cantidad_puntos_bancarios` int(11) DEFAULT 0,
  `tipo_puntos_bancarios` enum('alambrico','inalambrico','mixto') DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evaluacion_rack`
--

CREATE TABLE `evaluacion_rack` (
  `id` int(11) NOT NULL,
  `id_visita` int(11) NOT NULL,
  `red_estructurada` tinyint(1) DEFAULT 0,
  `posee_rack` tinyint(1) DEFAULT 0,
  `internet_fibra_optica` tinyint(1) DEFAULT 0,
  `router_switch_gigabits` tinyint(1) DEFAULT 0,
  `ups_router_switch_servidor` tinyint(1) DEFAULT 0,
  `servidor_dedicado` tinyint(1) DEFAULT 0,
  `cctv_dvr` tinyint(1) DEFAULT 0,
  `ups_dvr` tinyint(1) DEFAULT 0,
  `ups_cajas` tinyint(1) DEFAULT 0,
  `ups_impresora_fiscal` tinyint(1) DEFAULT 0,
  `ups_equipos_admin` tinyint(1) DEFAULT 0,
  `mini_ups_biometrico` tinyint(1) DEFAULT 0,
  `ups_puntos_bancarios` tinyint(1) DEFAULT 0,
  `impresora_local_red` tinyint(1) DEFAULT 0,
  `modelo_router` varchar(100) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grupos`
--

CREATE TABLE `grupos` (
  `id_grupo` varchar(3) NOT NULL,
  `nombre_grupo` varchar(100) NOT NULL,
  `duenos` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `observaciones_generales`
--

CREATE TABLE `observaciones_generales` (
  `id` int(11) NOT NULL,
  `id_visita` int(11) NOT NULL,
  `observacion` text NOT NULL,
  `tipo_observacion` enum('general','problema','recomendacion','urgente') DEFAULT 'general',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores_internet`
--

CREATE TABLE `proveedores_internet` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sedes`
--

CREATE TABLE `sedes` (
  `id` int(11) NOT NULL,
  `id_grupo` varchar(3) NOT NULL,
  `nombre_sede` varchar(100) NOT NULL,
  `rif` varchar(20) DEFAULT NULL,
  `direccion` text DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `estado` enum('activa','inactiva') DEFAULT 'activa',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tecnicos`
--

CREATE TABLE `tecnicos` (
  `id` int(11) NOT NULL,
  `cedula` varchar(20) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `cargo` varchar(50) DEFAULT 'TECNICO',
  `email` varchar(100) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `contrasena` varchar(255) NOT NULL,
  `activo` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `visitas`
--

CREATE TABLE `visitas` (
  `id` int(11) NOT NULL,
  `id_sede` int(11) NOT NULL,
  `id_tecnico` int(11) NOT NULL,
  `fecha_visita` date NOT NULL,
  `hora_inicio` time DEFAULT NULL,
  `hora_fin` time DEFAULT NULL,
  `estado` enum('pendiente','en_proceso','completada','cancelada') DEFAULT 'pendiente',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_equipos_por_sede`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_equipos_por_sede` (
`nombre_sede` varchar(100)
,`nombre_grupo` varchar(100)
,`fecha_visita` date
,`tipo_equipo` enum('servidor','administrativo','caja')
,`numero_equipo` int(11)
,`procesador` varchar(100)
,`ram_gb` int(11)
,`disco_gb` int(11)
,`sistema_operativo` varchar(50)
,`usuario_final` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_evaluacion_completa`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_evaluacion_completa` (
`visita_id` int(11)
,`fecha_visita` date
,`nombre_sede` varchar(100)
,`nombre_grupo` varchar(100)
,`tecnico` varchar(101)
,`red_estructurada` tinyint(1)
,`posee_rack` tinyint(1)
,`internet_fibra_optica` tinyint(1)
,`servidor_dedicado` tinyint(1)
,`posee_interbancario` tinyint(1)
,`cantidad_impresoras_fiscal` int(11)
,`cantidad_puntos_bancarios` int(11)
,`proveedor_internet` varchar(100)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_resumen_visitas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_resumen_visitas` (
`id` int(11)
,`fecha_visita` date
,`nombre_sede` varchar(100)
,`nombre_grupo` varchar(100)
,`tecnico` varchar(101)
,`estado` enum('pendiente','en_proceso','completada','cancelada')
,`created_at` timestamp
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_equipos_por_sede`
--
DROP TABLE IF EXISTS `vista_equipos_por_sede`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_equipos_por_sede`  AS SELECT `s`.`nombre_sede` AS `nombre_sede`, `g`.`nombre_grupo` AS `nombre_grupo`, `v`.`fecha_visita` AS `fecha_visita`, `e`.`tipo_equipo` AS `tipo_equipo`, `e`.`numero_equipo` AS `numero_equipo`, `e`.`procesador` AS `procesador`, `e`.`ram_gb` AS `ram_gb`, `e`.`disco_gb` AS `disco_gb`, `e`.`sistema_operativo` AS `sistema_operativo`, `e`.`usuario_final` AS `usuario_final` FROM (((`equipos` `e` join `visitas` `v` on(`e`.`id_visita` = `v`.`id`)) join `sedes` `s` on(`v`.`id_sede` = `s`.`id`)) join `grupos` `g` on(`s`.`id_grupo` = `g`.`id_grupo`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_evaluacion_completa`
--
DROP TABLE IF EXISTS `vista_evaluacion_completa`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_evaluacion_completa`  AS SELECT `v`.`id` AS `visita_id`, `v`.`fecha_visita` AS `fecha_visita`, `s`.`nombre_sede` AS `nombre_sede`, `g`.`nombre_grupo` AS `nombre_grupo`, concat(`t`.`nombre`,' ',`t`.`apellido`) AS `tecnico`, `er`.`red_estructurada` AS `red_estructurada`, `er`.`posee_rack` AS `posee_rack`, `er`.`internet_fibra_optica` AS `internet_fibra_optica`, `er`.`servidor_dedicado` AS `servidor_dedicado`, `ei`.`posee_interbancario` AS `posee_interbancario`, `ei`.`cantidad_impresoras_fiscal` AS `cantidad_impresoras_fiscal`, `ei`.`cantidad_puntos_bancarios` AS `cantidad_puntos_bancarios`, `pi`.`nombre` AS `proveedor_internet` FROM ((((((`visitas` `v` join `sedes` `s` on(`v`.`id_sede` = `s`.`id`)) join `grupos` `g` on(`s`.`id_grupo` = `g`.`id_grupo`)) join `tecnicos` `t` on(`v`.`id_tecnico` = `t`.`id`)) left join `evaluacion_rack` `er` on(`v`.`id` = `er`.`id_visita`)) left join `evaluacion_informatica` `ei` on(`v`.`id` = `ei`.`id_visita`)) left join `proveedores_internet` `pi` on(`ei`.`id_proveedor_internet` = `pi`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_resumen_visitas`
--
DROP TABLE IF EXISTS `vista_resumen_visitas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_resumen_visitas`  AS SELECT `v`.`id` AS `id`, `v`.`fecha_visita` AS `fecha_visita`, `s`.`nombre_sede` AS `nombre_sede`, `g`.`nombre_grupo` AS `nombre_grupo`, concat(`t`.`nombre`,' ',`t`.`apellido`) AS `tecnico`, `v`.`estado` AS `estado`, `v`.`created_at` AS `created_at` FROM (((`visitas` `v` join `sedes` `s` on(`v`.`id_sede` = `s`.`id`)) join `grupos` `g` on(`s`.`id_grupo` = `g`.`id_grupo`)) join `tecnicos` `t` on(`v`.`id_tecnico` = `t`.`id`)) ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `archivos_adjuntos`
--
ALTER TABLE `archivos_adjuntos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_visita` (`id_visita`);

--
-- Indices de la tabla `equipos`
--
ALTER TABLE `equipos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_tipo_equipo` (`tipo_equipo`),
  ADD KEY `idx_visita_tipo` (`id_visita`,`tipo_equipo`),
  ADD KEY `idx_equipos_visita_tipo` (`id_visita`,`tipo_equipo`);

--
-- Indices de la tabla `evaluacion_informatica`
--
ALTER TABLE `evaluacion_informatica`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_visita` (`id_visita`),
  ADD KEY `id_proveedor_internet` (`id_proveedor_internet`);

--
-- Indices de la tabla `evaluacion_rack`
--
ALTER TABLE `evaluacion_rack`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_visita` (`id_visita`);

--
-- Indices de la tabla `grupos`
--
ALTER TABLE `grupos`
  ADD PRIMARY KEY (`id_grupo`);

--
-- Indices de la tabla `observaciones_generales`
--
ALTER TABLE `observaciones_generales`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_visita` (`id_visita`);

--
-- Indices de la tabla `proveedores_internet`
--
ALTER TABLE `proveedores_internet`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `sedes`
--
ALTER TABLE `sedes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `rif` (`rif`),
  ADD KEY `idx_sedes_grupo` (`id_grupo`);

--
-- Indices de la tabla `tecnicos`
--
ALTER TABLE `tecnicos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cedula` (`cedula`);

--
-- Indices de la tabla `visitas`
--
ALTER TABLE `visitas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id_sede` (`id_sede`),
  ADD KEY `id_tecnico` (`id_tecnico`),
  ADD KEY `idx_visitas_fecha` (`fecha_visita`),
  ADD KEY `idx_visitas_estado` (`estado`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `archivos_adjuntos`
--
ALTER TABLE `archivos_adjuntos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `equipos`
--
ALTER TABLE `equipos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `evaluacion_informatica`
--
ALTER TABLE `evaluacion_informatica`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `evaluacion_rack`
--
ALTER TABLE `evaluacion_rack`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `observaciones_generales`
--
ALTER TABLE `observaciones_generales`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `proveedores_internet`
--
ALTER TABLE `proveedores_internet`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `sedes`
--
ALTER TABLE `sedes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tecnicos`
--
ALTER TABLE `tecnicos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `visitas`
--
ALTER TABLE `visitas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `archivos_adjuntos`
--
ALTER TABLE `archivos_adjuntos`
  ADD CONSTRAINT `archivos_adjuntos_ibfk_1` FOREIGN KEY (`id_visita`) REFERENCES `visitas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `equipos`
--
ALTER TABLE `equipos`
  ADD CONSTRAINT `equipos_ibfk_1` FOREIGN KEY (`id_visita`) REFERENCES `visitas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `evaluacion_informatica`
--
ALTER TABLE `evaluacion_informatica`
  ADD CONSTRAINT `evaluacion_informatica_ibfk_1` FOREIGN KEY (`id_visita`) REFERENCES `visitas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `evaluacion_informatica_ibfk_2` FOREIGN KEY (`id_proveedor_internet`) REFERENCES `proveedores_internet` (`id`);

--
-- Filtros para la tabla `evaluacion_rack`
--
ALTER TABLE `evaluacion_rack`
  ADD CONSTRAINT `evaluacion_rack_ibfk_1` FOREIGN KEY (`id_visita`) REFERENCES `visitas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `observaciones_generales`
--
ALTER TABLE `observaciones_generales`
  ADD CONSTRAINT `observaciones_generales_ibfk_1` FOREIGN KEY (`id_visita`) REFERENCES `visitas` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `sedes`
--
ALTER TABLE `sedes`
  ADD CONSTRAINT `sedes_ibfk_1` FOREIGN KEY (`id_grupo`) REFERENCES `grupos` (`id_grupo`) ON DELETE CASCADE;

--
-- Filtros para la tabla `visitas`
--
ALTER TABLE `visitas`
  ADD CONSTRAINT `visitas_ibfk_1` FOREIGN KEY (`id_sede`) REFERENCES `sedes` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `visitas_ibfk_2` FOREIGN KEY (`id_tecnico`) REFERENCES `tecnicos` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
