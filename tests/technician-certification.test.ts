import { describe, it, expect, beforeEach, vi } from "vitest"

// Mock the Clarity contract interactions
const mockContractCalls = {
  registerTechnician: vi.fn(),
  getTechnicianProfile: vi.fn(),
  updateTechnicianProfile: vi.fn(),
  issueDeviceCertification: vi.fn(),
  getDeviceCertification: vi.fn(),
  registerCertificationAuthority: vi.fn(),
  isCertificationAuthority: vi.fn(),
  isCertifiedForDevice: vi.fn(),
}

// Mock technician profile data
const mockTechnicianData = {
  name: "John Wilson",
  organization: "MedTech Calibration Services",
  "license-number": "MT-2023-456",
  "license-expiry": 24600,
  "registration-time": 12345,
  active: true,
}

const mockCertificationData = {
  "certification-level": 3,
  "issued-by": "ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM",
  "issue-date": 12345,
  "expiry-date": 24600,
  "training-verification": "Completed GE Healthcare MRI Calibration Course #MRI-2023-T45",
}

describe("Technician Certification Contract", () => {
  beforeEach(() => {
    vi.resetAllMocks()
    
    mockContractCalls.getTechnicianProfile.mockResolvedValue(mockTechnicianData)
    mockContractCalls.getDeviceCertification.mockResolvedValue(mockCertificationData)
    mockContractCalls.registerTechnician.mockResolvedValue({
      value: true,
      type: "ok",
    })
    mockContractCalls.updateTechnicianProfile.mockResolvedValue({
      value: true,
      type: "ok",
    })
    mockContractCalls.issueDeviceCertification.mockResolvedValue({
      value: true,
      type: "ok",
    })
    mockContractCalls.registerCertificationAuthority.mockResolvedValue({
      value: true,
      type: "ok",
    })
    mockContractCalls.isCertificationAuthority.mockResolvedValue(true)
    mockContractCalls.isCertifiedForDevice.mockResolvedValue(true)
  })
  
  describe("registerTechnician", () => {
    it("should successfully register a new technician", async () => {
      const result = await mockContractCalls.registerTechnician(
          "John Wilson",
          "MedTech Calibration Services",
          "MT-2023-456",
          24600,
      )
      
      expect(mockContractCalls.registerTechnician).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
  })
  
  describe("getTechnicianProfile", () => {
    it("should return technician profile for a valid address", async () => {
      const result = await mockContractCalls.getTechnicianProfile("ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM")
      
      expect(mockContractCalls.getTechnicianProfile).toHaveBeenCalledTimes(1)
      expect(result).toEqual(mockTechnicianData)
    })
  })
  
  describe("issueDeviceCertification", () => {
    it("should successfully issue a device certification", async () => {
      const result = await mockContractCalls.issueDeviceCertification(
          "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG",
          "MRI Scanner",
          3,
          24600,
          "Completed GE Healthcare MRI Calibration Course #MRI-2023-T45",
      )
      
      expect(mockContractCalls.issueDeviceCertification).toHaveBeenCalledTimes(1)
      expect(result.type).toBe("ok")
      expect(result.value).toBe(true)
    })
  })
  
  describe("isCertifiedForDevice", () => {
    it("should correctly verify if a technician is certified for a device", async () => {
      const result = await mockContractCalls.isCertifiedForDevice(
          "ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG",
          "MRI Scanner",
      )
      
      expect(mockContractCalls.isCertifiedForDevice).toHaveBeenCalledTimes(1)
      expect(result).toBe(true)
    })
  })
})

