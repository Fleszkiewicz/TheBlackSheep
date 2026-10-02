import { PoolConnection } from "mysql2/promise";
import { db } from "../db/db";
import { QueryExecutor } from "../core/QueryExecutor";
import { UserDTO } from "../dtos/auth.dto";

/**
 * Repositorio para operaciones de base de datos relacionadas con usuarios
 */
export class UserRepository {
  async getConnection(): Promise<PoolConnection> {
    return db.getConnection();
  }

  async findByEmail(
    email: string,
    conn?: PoolConnection
  ): Promise<UserDTO | null> {
    const cleanEmail = email.trim().toLowerCase();
    const result = await QueryExecutor.executeSelectOne<UserDTO>(
      "SELECT * FROM usuario u WHERE LOWER(TRIM(u.email)) = ?",
      [cleanEmail],
      conn
    );

    return result;
  }

  async findByEmails(
    emails: string[],
    conn?: PoolConnection
  ): Promise<UserDTO | null> {
    if (!emails || emails.length === 0) return null;
    const cleanEmails = emails
      .map((e) => e?.trim().toLowerCase())
      .filter((e): e is string => Boolean(e));
    if (cleanEmails.length === 0) return null;

    const placeholders = cleanEmails.map(() => "?").join(",");
    const result = await QueryExecutor.executeSelectOne<UserDTO>(
      `SELECT * FROM usuario u WHERE LOWER(TRIM(u.email)) IN (${placeholders}) LIMIT 1`,
      cleanEmails,
      conn
    );

    return result;
  }
}
