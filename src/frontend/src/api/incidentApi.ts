import client from "./axiosClient";
import { IncidentDTO } from "../dto/incidentdto";

export const getIncidents = async(): Promise<IncidentDTO[]> => {
    console.log("BASE URL:", process.env.REACT_APP_API_URL);

    const response = await client.get("/incidents");
    
    console.log(response);

    return response.data;
};

export const createIncident = async(payload: Partial<IncidentDTO>): Promise<IncidentDTO> => {
    const response = await client.post("/incidents", payload);
    console.log(response);
    return response.data;
};