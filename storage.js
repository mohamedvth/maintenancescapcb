// Sauvegarde les interventions et nextId dans le localStorage
function saveInterventionsToStorage(interventions, nextId) {
    const data = { interventions, nextId };
    localStorage.setItem('scapcb-data', JSON.stringify(data));
}

// Charge les interventions et nextId depuis le localStorage
function loadInterventionsFromStorage() {
    const stored = localStorage.getItem('scapcb-data');
    if (stored) {
        try {
            const parsed = JSON.parse(stored);
            return {
                interventions: Array.isArray(parsed.interventions) ? parsed.interventions : [],
                nextId: typeof parsed.nextId === 'number' ? parsed.nextId : 1
            };
        } catch {
            return { interventions: [], nextId: 1 };
        }
    }
    return { interventions: [], nextId: 1 };
}

// Efface toutes les données d'interventions du localStorage
function clearInterventionsStorage() {
    localStorage.removeItem('scapcb-data');
}