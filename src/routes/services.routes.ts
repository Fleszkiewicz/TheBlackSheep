import { Router } from "express";
import DIContainer from "../core/DIContainer";

const router = Router();

/**
 * @swagger
 * /api/services:
 *   get:
 *     summary: Obtener lista de servicios disponibles
 *     description: Retorna todos los tipos de servicios disponibles que se pueden asociar a un viaje (Hotel, Transporte, etc.)
 *     tags: [Servicios]
 *     security:
 *       - BearerAuth: []
 *     responses:
 *       200:
 *         description: Lista de servicios obtenida exitosamente
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: Servicios obtenidos exitosamente
 *                 data:
 *                   type: array
 *                   items:
 *                     $ref: '#/components/schemas/ServiceResponseDTO'
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 *             example:
 *               success: true
 *               message: Servicios obtenidos exitosamente
 *               data:
 *                 - id: 1
 *                   nombre: Hotel
 *                   descripcion: Alojamiento en hoteles
 *                 - id: 2
 *                   nombre: Transporte
 *                   descripcion: Servicios de transporte terrestre
 *                 - id: 3
 *                   nombre: Alimentación
 *                   descripcion: Comidas y bebidas
 *                 - id: 4
 *                   nombre: Tours
 *                   descripcion: Excursiones y actividades turísticas
 *               timestamp: '2025-10-19T12:00:00Z'
 *       401:
 *         $ref: '#/components/responses/UnauthorizedError'
 *       500:
 *         $ref: '#/components/responses/ServerError'
 */
router.get("/", DIContainer.getServicesController().getServices);

export default router;
