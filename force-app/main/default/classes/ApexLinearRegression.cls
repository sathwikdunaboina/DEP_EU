public class ApexLinearRegression {

    public class ModelResult {
        public Decimal intercept;
        public List<Decimal> coefficients;

        public ModelResult(Decimal intercept, List<Decimal> coefficients) {
            this.intercept = intercept;
            this.coefficients = coefficients;
        }

        public override String toString() {
            return 'Intercept: ' + intercept + '\nCoefficients: ' + coefficients;
        }
    }

    public static ModelResult trainModel(List<Case> cases) {
        List<CaseFeature> features = new List<CaseFeature>();
        for (Case c : cases) {
            if (c.CreatedDate != null && c.ClosedDate != null) {
                features.add(new CaseFeature(c));
            }
        }

        if (features.size() == 0) {
            throw new AuraHandledException('No valid training data found.');
        }

        Integer featureCount = features[0].toFeatureVector().size();
        Integer n = features.size();

        List<List<Decimal>> X = new List<List<Decimal>>();
        List<List<Decimal>> Y = new List<List<Decimal>>();

        for (CaseFeature f : features) {
            List<Decimal> row = f.toFeatureVector();
            X.add(row);
            Y.add(new List<Decimal>{f.target});
        }

        List<List<Decimal>> Xt = transpose(X);
        List<List<Decimal>> XtX = multiply(Xt, X);
        List<List<Decimal>> XtY = multiply(Xt, Y);

        List<List<Decimal>> XtX_inv;
        try {
            XtX_inv = invertMatrix(XtX);
        } catch (Exception e) {
            throw new AuraHandledException('Matrix inversion failed: ' + e.getMessage());
        }

        List<List<Decimal>> W = multiply(XtX_inv, XtY);
        Decimal intercept = W[0][0];
        List<Decimal> coefficients = new List<Decimal>();

        for (Integer i = 1; i < W.size(); i++) {
            coefficients.add(W[i][0]);
        }

        return new ModelResult(intercept, coefficients);
    }

    public class CaseFeature {
        public Decimal isEscalated;
        public Decimal priorityLow;
        public Decimal priorityMedium;
        public Decimal priorityHigh;
        public List<Decimal> typeOneHot;
        public Decimal createdDate;
        public Decimal target;

        public  List<String> typeCategories = new List<String>{
            'Additional Services query',
            'Change my details',
            'Claims',
            'Contract Hire',
            'Customer Feedback',
            'Customer Portal',
            'End of term query',
            'Excess Meterage Query',
            'Financial Contract query',
            'General query / Miscellaneous',
            'General Service Enquiry',
            'General Services query',
            'Insurance query',
            'Invoice or payment or tax query',
            'Problems with Web Portal',
            'Request Copy Document',
            'RFL',
            'Sales Support',
            'Contact with Sales rep'
        };

        public CaseFeature(Case c) {
            isEscalated = (c.IsEscalated == true) ? 1 : 0;

            priorityLow = (c.Priority == 'Low') ? 1 : 0;
            priorityMedium = (c.Priority == 'Medium') ? 1 : 0;
            priorityHigh = (c.Priority == 'High') ? 1 : 0;

            typeOneHot = new List<Decimal>();
            for (String typeVal : typeCategories) {
                typeOneHot.add(c.Type == typeVal ? 1 : 0);
            }

            createdDate = (Decimal)(c.CreatedDate.getTime() / 1000);
            target = (Decimal)(c.ClosedDate.getTime() / 1000);
        }

        public List<Decimal> toFeatureVector() {
            List<Decimal> features = new List<Decimal>{1, isEscalated, priorityLow, priorityMedium, priorityHigh};
            features.addAll(typeOneHot);
            features.add(createdDate);
            return features;
        }
    }

    // Matrix operations

    public static List<List<Decimal>> transpose(List<List<Decimal>> m) {
        Integer rows = m.size();
        Integer cols = m[0].size();
        List<List<Decimal>> result = new List<List<Decimal>>();

        for (Integer i = 0; i < cols; i++) {
            List<Decimal> row = new List<Decimal>();
            for (Integer j = 0; j < rows; j++) {
                row.add(m[j][i]);
            }
            result.add(row);
        }
        return result;
    }

    public static List<List<Decimal>> multiply(List<List<Decimal>> A, List<List<Decimal>> B) {
        Integer rowsA = A.size();
        Integer colsA = A[0].size();
        Integer colsB = B[0].size();
        List<List<Decimal>> result = new List<List<Decimal>>();

        for (Integer i = 0; i < rowsA; i++) {
            List<Decimal> row = new List<Decimal>();
            for (Integer j = 0; j < colsB; j++) {
                Decimal sum = 0;
                for (Integer k = 0; k < colsA; k++) {
                    sum += A[i][k] * B[k][j];
                }
                row.add(sum);
            }
            result.add(row);
        }
        return result;
    }

    public static List<List<Decimal>> invertMatrix(List<List<Decimal>> matrix) {
        Integer n = matrix.size();
        for (List<Decimal> row : matrix) {
            if (row.size() != n) {
                throw new AuraHandledException('Matrix must be square.');
            }
        }

        List<List<Decimal>> a = new List<List<Decimal>>();
        List<List<Decimal>> inv = new List<List<Decimal>>();

        for (Integer i = 0; i < n; i++) {
            List<Decimal> rowA = new List<Decimal>();
            List<Decimal> rowI = new List<Decimal>();
            for (Integer j = 0; j < n; j++) {
                rowA.add(matrix[i][j]);
                rowI.add(i == j ? 1 : 0);
            }
            a.add(rowA);
            inv.add(rowI);
        }

        for (Integer i = 0; i < n; i++) {
            Decimal pivot = a[i][i];
            if (pivot == 0) {
                Boolean swapped = false;
                for (Integer j = i + 1; j < n; j++) {
                    if (a[j][i] != 0) {
                        swapRows(a, i, j);
                        swapRows(inv, i, j);
                        pivot = a[i][i];
                        swapped = true;
                        break;
                    }
                }
                if (!swapped) {
                    throw new AuraHandledException('Matrix is singular and cannot be inverted.');
                }
            }

            for (Integer j = 0; j < n; j++) {
                a[i][j] = a[i][j] / pivot;
                inv[i][j] = inv[i][j] / pivot;
            }

            for (Integer k = 0; k < n; k++) {
                if (k != i) {
                    Decimal factor = a[k][i];
                    for (Integer j = 0; j < n; j++) {
                        a[k][j] -= factor * a[i][j];
                        inv[k][j] -= factor * inv[i][j];
                    }
                }
            }
        }

        return inv;
    }

    private static void swapRows(List<List<Decimal>> matrix, Integer i, Integer j) {
        List<Decimal> temp = matrix[i];
        matrix[i] = matrix[j];
        matrix[j] = temp;
    }
}