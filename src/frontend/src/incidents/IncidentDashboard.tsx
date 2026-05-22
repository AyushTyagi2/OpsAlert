import {MetricCard} from "../components/MetricCard";
import {AlertCircle, AlertTriangle, CheckCircle} from "lucide-react";
import {useState, useEffect} from "react";
import {IncidentDTO} from "../dto/incidentdto";
import { getIncidents } from "../api/incidentApi";



function IncidentDashboard() {
const [Incidents, setIncidents] = useState<IncidentDTO[]>([]);
useEffect(() => {
  loadIncidents();
}, []);

const loadIncidents = async () => {
  try{
    const data = await getIncidents();
    setIncidents(data);
  }catch(error){
    console.error(error);
  }
};
  return (
    <div className="m-5">
      <h1 className="text-4xl font-bold mb-6 ">
        Operations Dashboard
      </h1>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <MetricCard
          title="Total Incidents"
          value="12"
          change="+2 from last week"
          trend="up"
          icon={<AlertCircle className="w-5 h-5 text-red-400" />}

        />
        <MetricCard
          title="Critical Incidents"
          value="3"
          change="+1 from last week"
          trend="up"
          icon={<AlertTriangle className="w-5 h-5 text-orange-400" />}

        />
        <MetricCard
          title="Resolved Today"
          value="5"
          change="+3 from last week"
          trend="up"
          icon={<CheckCircle className="w-5 h-5 text-green-400" />}
        />
      </div>

      <div className="mt-8">
        <h2 className="text-2xl font-semibold mb-4">
          Active Incidents
        </h2>

        <div className="space-y-4">
          {Incidents.map((incident) => (
            <div
              key={incident.id}
              className="bg-slate-900 border border-slate-800 rounded-lg p-4"
            >
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-lg font-semibold">
                    {incident.title}
                  </h3>

                  <p className="text-slate-400 mt-1">
                    {incident.status}
                  </p>
                </div>

                <span className="bg-red-500 text-white px-3 py-1 rounded-full text-sm">
                  {incident.severity}
                </span>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default IncidentDashboard;