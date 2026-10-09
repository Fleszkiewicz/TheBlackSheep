import mysql from "mysql2/promise";
import dotenv from "dotenv";
import path from "path";
import fs from "fs/promises";
import readline from "readline/promises";

// Sin flag -> .env.dev (pruebas). Con --prod -> .env (producción)
const isProd = process.argv.includes("--prod");
dotenv.config({
    path: path.resolve(process.cwd(), isProd ? ".env" : ".env.dev"),
});

const MIGRATIONS_DIR = path.resolve(process.cwd(), "migrations");

async function confirmProd(dbName: string, host: string) {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
    });
    console.log(`\n⚠️  VAS A MODIFICAR PRODUCCIÓN: ${dbName} en ${host}`);
    const answer = await rl.question(
        `Escribí el nombre de la base para continuar: `,
    );
    rl.close();
    if (answer.trim() !== dbName) {
        console.log("Cancelado. No se tocó nada.");
        process.exit(0);
    }
}

async function migrate() {
    const dbName = process.env.DB_NAME!;
    const host = process.env.DB_HOST!;

    const connection = await mysql.createConnection({
        host,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: dbName,
        port: process.env.DB_PORT ? Number(process.env.DB_PORT) : 3306,
    });

    console.log(`🔌 Conectado a ${dbName} en ${host}`);

    try {
        // Tabla que recuerda qué migraciones ya se aplicaron
        await connection.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        name VARCHAR(255) PRIMARY KEY,
        applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

        const [rows]: any = await connection.query(
            "SELECT name FROM schema_migrations",
        );
        const applied = new Set<string>(rows.map((r: any) => r.name));

        const files = (await fs.readdir(MIGRATIONS_DIR))
            .filter((f) => f.endsWith(".sql"))
            .sort();

        const pending = files.filter((f) => !applied.has(f));

        if (pending.length === 0) {
            console.log("✅ Todo al día, no hay migraciones pendientes.");
            return;
        }

        console.log("Pendientes:", pending.join(", "));

        if (isProd) await confirmProd(dbName, host);

        for (const file of pending) {
            console.log(`▶️  Aplicando ${file}...`);
            const content = await fs.readFile(
                path.join(MIGRATIONS_DIR, file),
                "utf-8",
            );

            // Las sentencias se separan con ';;'
            const statements = content
                .split(";;")
                .map((s) => s.trim())
                .filter(Boolean);

            for (const statement of statements) {
                await connection.query(statement);
            }

            await connection.query(
                "INSERT INTO schema_migrations (name) VALUES (?)",
                [file],
            );
            console.log(`✅ ${file} aplicada`);
        }

        console.log("🎉 Migraciones al día.");
    } catch (error) {
        // Si una falla, frenamos: nunca seguir a medias
        console.error("❌ Falló, se detiene el proceso:", error);
        process.exitCode = 1;
    } finally {
        await connection.end();
    }
}

migrate();