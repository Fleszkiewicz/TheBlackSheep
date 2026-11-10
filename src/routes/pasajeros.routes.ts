import { Router } from "express";
import DIContainer from "../core/DIContainer";

const router = Router();

router.get("/", DIContainer.getPasajerosController().buscar);

export default router;