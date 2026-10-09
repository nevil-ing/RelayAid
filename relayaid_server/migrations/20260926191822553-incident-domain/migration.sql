BEGIN;

--
-- Function: gen_random_uuid_v7()
-- Source: https://gist.github.com/kjmph/5bd772b2c2df145aa645b837da7eca74
-- License: MIT (copyright notice included on the generator source code).
--
create or replace function gen_random_uuid_v7()
returns uuid
as $$
begin
  -- use random v4 uuid as starting point (which has the same variant we need)
  -- then overlay timestamp
  -- then set version 7 by flipping the 2 and 1 bit in the version 4 string
  return encode(
    set_bit(
      set_bit(
        overlay(uuid_send(gen_random_uuid())
                placing substring(int8send(floor(extract(epoch from clock_timestamp()) * 1000)::bigint) from 3)
                from 1 for 6
        ),
        52, 1
      ),
      53, 1
    ),
    'hex')::uuid;
end
$$
language plpgsql
volatile;

--
-- ACTION CREATE TABLE
--
CREATE TABLE "relay_incident" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "organizationId" uuid NOT NULL,
    "type" text NOT NULL,
    "severity" text NOT NULL,
    "status" text NOT NULL,
    "title" text NOT NULL,
    "description" text NOT NULL,
    "latitude" double precision,
    "longitude" double precision,
    "peopleAffected" bigint NOT NULL,
    "reportedBy" uuid NOT NULL,
    "reportedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "relay_incident_organization_updated" ON "relay_incident" USING btree ("organizationId", "updatedAt");
CREATE INDEX "relay_incident_organization_status" ON "relay_incident" USING btree ("organizationId", "status");

--
-- ACTION CREATE TABLE
--
CREATE TABLE "relay_incident_event" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid_v7(),
    "incidentId" uuid NOT NULL,
    "organizationId" uuid NOT NULL,
    "eventType" text NOT NULL,
    "actorId" uuid NOT NULL,
    "fromStatus" text,
    "toStatus" text,
    "note" text,
    "createdAt" timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX "relay_incident_event_incident_created" ON "relay_incident_event" USING btree ("incidentId", "createdAt");


--
-- MIGRATION VERSION FOR relayaid
--
INSERT INTO "serverpod_migrations" ("module", "version", "timestamp")
    VALUES ('relayaid', '20260926191822553-incident-domain', now())
    ON CONFLICT ("module")
    DO UPDATE SET "version" = '20260926191822553-incident-domain', "timestamp" = now();

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
