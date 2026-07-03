import mongoose from "mongoose";

export async function connectDb(){
    try {
        const mongourl=process.env.DB_URL

        if(!mongourl){
            throw new Error("mongourl is required");

        }

       const conn= await mongoose.connect(mongourl)

        console.log("db connected",conn.connection.host)
    } catch (error) {
        console.error("error got occured",error.message);
        process.exit(1)
    }
}