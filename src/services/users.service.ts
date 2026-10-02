import { UserRepository } from "../repositories/user.repository";
import { UserDTO } from "../dtos/auth.dto";
import { ErrorFactory } from "../errors/errorFactory";
import logger from "../config/logger.config";

/**
 * Servicio de usuarios con lógica de negocio
 */
export class UserService {
  constructor(private userRepository: UserRepository) {}

  /**
   * Obtener usuario por email
   */
  async getUserByEmail(email: string): Promise<UserDTO> {
    logger.info("Fetching user by email", { email });

    const user = await this.userRepository.findByEmail(email);

    if (!user) {
      throw ErrorFactory.notFound("Usuario no encontrado");
    }

    return user;
  }

  /**
   * Obtener usuario buscando en una lista de emails posibles
   */
  async getUserByEmails(emails: string[]): Promise<UserDTO> {
    logger.info("Fetching user by emails", { emails });

    const user = await this.userRepository.findByEmails(emails);

    if (!user) {
      throw ErrorFactory.notFound("Usuario no encontrado");
    }

    return user;
  }
}
