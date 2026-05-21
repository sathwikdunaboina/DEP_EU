/**
* ISO 3779 Bulk VIN Validator for EMEA Region
*
* ISO 3779 Structure (17 characters):
* - WMI : Positions 1–3 (World Manufacturer Identifier)
* - VDS : Positions 4–9 (Vehicle Descriptor Section)
* - VIS : Positions 10–17 (Vehicle Identifier Section)
*
* EMEA Notes:
* - Check digit (position 9) is NOT mandated by ISO 3779 / EU regulations,
* unlike the US NHTSA standard. This validator skips check-digit enforcement
* but flags it as a warning if present and invalid.
* - WMI region codes for EMEA: A–H (Africa), S–Z (Europe), 8–9 (Middle East/some EMEA)
* - Forbidden characters: I, O, Q (ISO 3779 §4)
*
* Fix log:
* - Removed redundant FORBIDDEN_CHARS loop; ALLOWED_CHARS is the single source of
* truth. A separate branch now emits the specific "Forbidden character" message
* only when the offending char is I, O, or Q, so callers still get the precise
* error without double-reporting.
* - validateCheckDigit is now guarded by result.isValid so a VIN that already
* failed character/length checks never produces a spurious check-digit warning.
* - Added position-weight comment explaining why weight[8] == 0.
*/
public with sharing class VINValidator {
    
    // ── Constants ────────────────────────────────────────────────────────────
    private static final Integer VIN_LENGTH = 17;
    private static final String ALLOWED_CHARS = 'ABCDEFGHJKLMNPRSTUVWXYZ0123456789';
    private static final String FORBIDDEN_CHARS = 'IOQ'; // retained for specific error messages only
    
    // EMEA WMI first-character ranges
    // Africa: A–H | Europe: S–Z | Middle East / broader EMEA: 8–9
    private static final Set<String> EMEA_WMI_FIRST_CHARS = new Set<String>{
        'A','B','C','D','E','F','G','H', // Africa
            'S','T','U','V','W','X','Y','Z', // Europe
            '8','9' // Middle East / Rest of EMEA
            };
                
                // Transliteration table for check-digit calculation (US NHTSA / ISO annex)
                private static final Map<String, Integer> TRANSLITERATION = new Map<String, Integer>{
                    'A'=>1,'B'=>2,'C'=>3,'D'=>4,'E'=>5,'F'=>6,'G'=>7,'H'=>8,
                        'J'=>1,'K'=>2,'L'=>3,'M'=>4,'N'=>5, 'P'=>7,'R'=>9,
                        'S'=>2,'T'=>3,'U'=>4,'V'=>5,'W'=>6,'X'=>7,'Y'=>8,'Z'=>9,
                        '0'=>0,'1'=>1,'2'=>2,'3'=>3,'4'=>4,'5'=>5,'6'=>6,'7'=>7,'8'=>8,'9'=>9
                        };
                            
                            // Position weights per NHTSA / ISO annex.
                            // Weight at index 8 (position 9, the check-digit slot) is intentionally 0
                            // so it does not contribute to the sum before the remainder is computed.
                            private static final List<Integer> POSITION_WEIGHTS = new List<Integer>{
                                8, 7, 6, 5, 4, 3, 2, 10, 0, 9, 8, 7, 6, 5, 4, 3, 2
                                    };
                                        
                                        // ── Result wrapper ───────────────────────────────────────────────────────
                                        public class VINResult {
                                            @AuraEnabled public String vin { get; set; }
                                            @AuraEnabled public Boolean isValid { get; set; }
                                            @AuraEnabled public String wmi { get; set; }
                                            @AuraEnabled public String vds { get; set; }
                                            @AuraEnabled public String vis { get; set; }
                                            @AuraEnabled public String region { get; set; }
                                            @AuraEnabled public List<String> errors { get; set; }
                                            @AuraEnabled public List<String> warnings { get; set; }
                                            
                                            public VINResult(String vin) {
                                                this.vin = vin;
                                                this.isValid = true;
                                                this.errors = new List<String>();
                                                this.warnings = new List<String>();
                                            }
                                        }
    
    // ── Public Bulk Entry Point ──────────────────────────────────────────────
    /**
* Validates a list of VIN strings in bulk.
* Bulkified: all string operations are O(n) with no SOQL/DML inside.
*
* @param vins List of raw VIN strings (nulls tolerated)
* @return List<VINResult> in the same order as input
*/
    public static List<VINResult> validateBulk(List<String> vins) {
        List<VINResult> results = new List<VINResult>();
        if (vins == null || vins.isEmpty()) return results;
        
        for (String rawVin : vins) {
            results.add(validateSingle(rawVin));
        }
        return results;
    }
    
    // ── Single VIN Validation ────────────────────────────────────────────────
    private static VINResult validateSingle(String rawVin) {
        
        VINResult result = new VINResult(rawVin);
        
        // ── Null / empty check ───────────────────────────────────────────────
        if (String.isBlank(rawVin)) {
            result.isValid = false;
            result.errors.add('VIN is null or empty');
            return result;
        }
        
        // ── Normalize (trim + uppercase) ─────────────────────────────────────
        String vin = rawVin.trim().toUpperCase();
        result.vin = vin;
        
        // ── Length check ─────────────────────────────────────────────────────
        if (vin.length() != VIN_LENGTH) {
            result.isValid = false;
            result.errors.add('Invalid VIN length: expected 17 characters, got ' + vin.length());
            return result;
        }
        
        // ── Character validation ─────────────────────────────────────────────
        // FIX: single loop, single check per character.
        // Previously, both ALLOWED_CHARS and FORBIDDEN_CHARS were checked
        // independently, causing I/O/Q to produce two errors each.
        // Now ALLOWED_CHARS is the gate; forbidden chars get a specific message.
        for (Integer i = 0; i < vin.length(); i++) {
            String ch = vin.substring(i, i + 1);
            
            if (!ALLOWED_CHARS.contains(ch)) {
                result.isValid = false;
                if (FORBIDDEN_CHARS.contains(ch)) {
                    result.errors.add('Forbidden character at position ' + (i + 1) + ': ' + ch + ' (I, O, Q are not allowed by ISO 3779)');
                } else {
                    result.errors.add('Invalid character at position ' + (i + 1) + ': ' + ch);
                }
            }
        }
        
        // ── Extract sections ─────────────────────────────────────────────────
        result.wmi = vin.substring(0, 3);
        result.vds = vin.substring(3, 9);
        result.vis = vin.substring(9, 17);
        
        // ── Region detection ─────────────────────────────────────────────────
        String firstChar = vin.substring(0, 1);
        if (EMEA_WMI_FIRST_CHARS.contains(firstChar)) {
            result.region = 'EMEA';
        } else {
            result.region = 'Non-EMEA';
            result.warnings.add('VIN does not appear to be from the EMEA region (first char: ' + firstChar + ')');
        }
        
        // ── Optional check-digit validation (non-blocking, EMEA advisory only)
        // FIX: only run when the VIN has passed all hard checks. Running it on
        // a VIN that already has character errors produces a misleading warning
        // because invalid chars have no transliteration value.
        if (result.isValid) {
            validateCheckDigit(vin, result);
        }
        
        return result;
    }
    
    // ── Check-Digit Calculation (NHTSA / ISO annex, advisory for EMEA) ───────
    private static void validateCheckDigit(String vin, VINResult result) {
        
        Integer sum = 0;
        
        for (Integer i = 0; i < vin.length(); i++) {
            String ch = vin.substring(i, i + 1);
            Integer value = TRANSLITERATION.get(ch);
            Integer weight = POSITION_WEIGHTS[i];
            
            if (value == null) {
                // Should not be reachable after the ALLOWED_CHARS guard above,
                // but kept as a safety net.
                result.warnings.add('Check digit skipped: no transliteration value for character "' + ch + '"');
                return;
            }
            
            sum += value * weight;
        }
        
        Integer remainder = Math.mod(sum, 11);
        String expected = (remainder == 10) ? 'X' : String.valueOf(remainder);
        String actual = vin.substring(8, 9); // position 9 (0-indexed: 8)
        
        if (expected != actual) {
            result.warnings.add(
                'Check digit mismatch (position 9): expected "' + expected +
                '", found "' + actual + '". Note: check digit is advisory for EMEA VINs.'
            );
        }
    }
}