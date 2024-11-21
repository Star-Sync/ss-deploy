-- PostgreSQL script

-- Schema creation
CREATE SCHEMA IF NOT EXISTS starsync;

-- Set search path to use this schema
SET search_path TO starsync;

-- Table `GroundStation`
CREATE TABLE IF NOT EXISTS GroundStation (
  Ground_StationID SERIAL NOT NULL,
  GroundStationName VARCHAR(45) NOT NULL,
  Latitude VARCHAR(45) NOT NULL,
  Longitude VARCHAR(45) NOT NULL,
  AntennaHeight DECIMAL NOT NULL,
  UplinkRate DECIMAL NULL,
  TeleDownlinkRate DECIMAL NOT NULL,
  SciDownlinkRate DECIMAL NOT NULL,
  StationMask DECIMAL NOT NULL,
  PRIMARY KEY (Ground_StationID)
);

-- Table `Mission`
CREATE TABLE IF NOT EXISTS Mission (
  MissionID SERIAL NOT NULL,
  MissionName VARCHAR(45) NOT NULL,
  PRIMARY KEY (MissionID)
);

-- Table `Satellite`
CREATE TABLE IF NOT EXISTS Satellite (
  SatelliteID SERIAL UNIQUE NOT NULL,
  SatelliteName VARCHAR(45) NOT NULL,
  Priority INT NOT NULL,
  TLE VARCHAR(200) NULL,
  UplinkRate DECIMAL NULL,
  TeleDownlinkRate DECIMAL NULL,
  SciDownlinkRate DECIMAL NULL,
  GroundStationID INT NOT NULL REFERENCES GroundStation(Ground_StationID) ON DELETE NO ACTION ON UPDATE NO ACTION,
  MissionID INT NOT NULL REFERENCES Mission(MissionID) ON DELETE NO ACTION ON UPDATE NO ACTION,
  PRIMARY KEY (SatelliteID, SatelliteName, GroundStationID, MissionID)
);

-- Table `ExclusionCone`
CREATE TABLE IF NOT EXISTS ExclusionCone (
  ExclusionConeID SERIAL NOT NULL,
  ConflictingSatelliteID VARCHAR(45) NOT NULL,
  GroundStationID INT NOT NULL REFERENCES GroundStation(Ground_StationID) ON DELETE NO ACTION ON UPDATE NO ACTION,
  AngleLimit DECIMAL NOT NULL,
  MissionID INT NOT NULL REFERENCES Mission(MissionID) ON DELETE NO ACTION ON UPDATE NO ACTION,
  SatelliteID INT NOT NULL REFERENCES Satellite(SatelliteID) ON DELETE NO ACTION ON UPDATE NO ACTION,
  PRIMARY KEY (ExclusionConeID, GroundStationID, MissionID, SatelliteID),
  FOREIGN KEY (GroundStationID) REFERENCES GroundStation(Ground_StationID) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (MissionID) REFERENCES Mission(MissionID) ON DELETE NO ACTION ON UPDATE NO ACTION,
  FOREIGN KEY (SatelliteID) REFERENCES Satellite(SatelliteID) ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Table `SatelliteOutage`
CREATE TABLE IF NOT EXISTS SatelliteOutage (
  SatelliteOutageID SERIAL NOT NULL,
  SatelliteID INT NOT NULL,
  StartTime TIMESTAMP NULL,
  EndTime TIMESTAMP NULL,
  PRIMARY KEY (SatelliteOutageID, SatelliteID),
  FOREIGN KEY (SatelliteID)
    REFERENCES Satellite(SatelliteID)
    ON DELETE NO ACTION ON UPDATE NO ACTION
);

-- Table `GroundStationOutage`
CREATE TABLE IF NOT EXISTS GroundStationOutage (
  GS_OutageID SERIAL NOT NULL,
  GroundStation_Ground_StationID INT NOT NULL,
  StartTime TIMESTAMP NOT NULL,
  EndTime TIMESTAMP NOT NULL,
  PRIMARY KEY (GS_OutageID, GroundStation_Ground_StationID),
  CONSTRAINT fk_GroundStationOutage_GroundStation1
    FOREIGN KEY (GroundStation_Ground_StationID)
    REFERENCES GroundStation(Ground_StationID)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION
);
-- Table `GS_RF_Request`
CREATE TABLE IF NOT EXISTS GS_RF_Request (
  GS_RF_Request_ID SERIAL PRIMARY KEY,
  MissionID INT NOT NULL REFERENCES Mission(MissionID) ON DELETE NO ACTION ON UPDATE NO ACTION,
  SatelliteID INT NOT NULL,
  StartTime TIMESTAMP NOT NULL,
  EndTime TIMESTAMP NOT NULL,
  UplinkTime INT NOT NULL,
  DownlinkTime INT NOT NULL,
  SciTime INT NOT NULL,
  MinPasses INT NOT NULL,
  CreatedAt TIMESTAMP,
  CreatedBy VARCHAR(45)
);

-- Table `GS_Contact_Request`
CREATE TABLE IF NOT EXISTS GS_Contact_Request (
  GS_Contact_Request_ID SERIAL PRIMARY KEY,
  MissionID INT NOT NULL REFERENCES Mission(MissionID) ON DELETE NO ACTION ON UPDATE NO ACTION,
  SatelliteID INT NOT NULL,
  GroundStationID INT NOT NULL,
  Orbit INT NOT NULL,
  Uplink BOOLEAN NOT NULL,
  Telemetry INT NOT NULL,
  Science INT NOT NULL,
  AOS TIMESTAMP NOT NULL,
  RF_On TIMESTAMP NOT NULL,
  RF_Off TIMESTAMP NOT NULL,
  LOS TIMESTAMP NOT NULL,
  CreatedAt TIMESTAMP NOT NULL,
  CreatedBy VARCHAR(45) NOT NULL
);

-- Reset search path
RESET search_path;
