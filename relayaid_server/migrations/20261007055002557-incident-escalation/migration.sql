BEGIN;

--
-- ACTION ALTER TABLE
--
ALTER TABLE "relay_incident" ADD COLUMN "escalationDueAt" timestamp without time zone;
ALTER TABLE "relay_incident" ADD COLUMN "escalatedAt" timestamp without time zone;
CREATE INDEX "relay_incident_escalation_due" ON "relay_incident" USING btree ("severity", "status", "escalationDueAt");
--
-- ACTION ALTER TABLE
--
ALTER TABLE "relay_incident_event" ALTER COLUMN "actorId" DROP NOT NULL;

--
-- MIGRATION VERSION FOR relayaid
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('relayaid', '20261007055002557-incident-escalation', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20261007055002557-incident-escalation', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod', '20260824182259319', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182259319', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_idp
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_idp', '20260910193913364-string-rate-limit-keys', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260910193913364-string-rate-limit-keys', "timestamp" = now();

--
-- MIGRATION VERSION FOR serverpod_auth_core
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('serverpod_auth_core', '20260824182354731', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260824182354731', "timestamp" = now();


COMMIT;
