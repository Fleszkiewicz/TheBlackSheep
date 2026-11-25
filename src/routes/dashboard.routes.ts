import { Router } from "express";
import { DashboardController } from "../controllers/dashboard.controller";
import { dashboardService } from "../services/dashboard.service";

const router = Router();
const dashboard = new DashboardController(dashboardService);

/**
 * @swagger
 * /api/dashboard/{vista}:
 *   get:
 *     summary: Datos de una sección del Dashboard
 *     description: KPI y series de gráficos de la sección pedida (ver DASHBOARD.md).
 *     tags: [Dashboard]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: vista
 *         required: true
 *         schema:
 *           type: string
 *           enum: [expedientes, productos, finanzas, expensas]
 *       - in: query
 *         name: anio
 *         required: true
 *         schema:
 *           type: integer
 *       - in: query
 *         name: mes
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 12
 *       - in: query
 *         name: sucursal
 *         schema:
 *           type: string
 *           enum: [baradero, hurlingham]
 *     responses:
 *       200:
 *         description: Datos de la sección
 *       400:
 *         description: Año faltante o inválido
 *       404:
 *         description: Sección inexistente
 */
router.get("/:vista", dashboard.getVista);

export default router;
