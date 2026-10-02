import passport from "passport";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import DIContainer from "../core/DIContainer";
import { generateAccessToken, generateRefreshToken } from "../utils/utils";
import config from "./config";
import logger from "./logger.config";
const userService = DIContainer.getUserService();

export function configurePassport(): void {
  passport.use(
    new GoogleStrategy(
      {
        clientID: config.GOOGLE_CLIENT_ID!,
        clientSecret: config.GOOGLE_CLIENT_SECRET!,
        callbackURL: config.GOOGLE_CALLBACK,
      },
      async (_accessToken, _refreshToken, profile, done) => {
        let candidateEmails: string[] = [];
        try {
          candidateEmails = (profile.emails || [])
            .map((e) => e.value?.trim().toLowerCase())
            .filter((e): e is string => Boolean(e));
          const avatar = profile.photos?.[0]?.value ?? "";

          if (candidateEmails.length === 0) {
            logger.warn("Google authentication failed - no email provided", {
              profileId: profile.id,
            });
            return done(null, false, { message: "No email provided" });
          }

          // Usar servicio para obtener usuario buscando por cualquiera de los emails devueltos por Google
          const user = await userService.getUserByEmails(candidateEmails);

          const { nombre, email } = user;

          // Generar tokens
          const accessToken = generateAccessToken({
            auth: true,
            email,
            nombre,
            avatar,
          });
          const refreshToken = generateRefreshToken({ email, nombre });

          logger.info("Google authentication successful", {
            email,
            candidateEmails,
          });

          return done(null, { user, accessToken, refreshToken });
        } catch (error) {
          logger.error("Google authentication error - user lookup failed", {
            candidateEmails,
            primaryEmail: profile.emails?.[0]?.value,
            allProfileEmails: profile.emails,
            error: error instanceof Error ? error.message : "Unknown error",
            stack: error instanceof Error ? error.stack : undefined,
          });
          return done(null, false, {
            message: candidateEmails[0] || "unauthorized",
          });
        }
      },
    ),
  );
}
