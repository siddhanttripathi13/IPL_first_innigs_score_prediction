# Importing required libraries
from flask import Flask, render_template, request
import pickle
import numpy as np

# Load the regression model, encoders and scaler
model = 'first-innings_score_predictor.pkl'
regressor = pickle.load(open(model, 'rb'))

venue_enocder = 'venue_encoder.pkl'
venue_enocder = pickle.load(open(venue_enocder, 'rb'))

bat_team_encoder = 'bat_team_encoder.pkl'
bat_team_encoder = pickle.load(open(bat_team_encoder, 'rb'))

bowl_team_encoder = 'bowl_team_encoder.pkl'
bowl_team_encoder = pickle.load(open(bowl_team_encoder, 'rb'))

scaler = 'scaler.pkl'
scaler = pickle.load(open(scaler, 'rb'))

app = Flask(__name__)


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/predict', methods=['POST'])
def predict():
    temp_array = list()

    if request.method == 'POST':

        venue = request.form['venue']
        # encoding venue
        temp_array += list(venue_enocder.transform(
            [[venue]]).toarray().flatten())

        batting_team = request.form['batting-team']
        # encoding batting team
        temp_array += list(bat_team_encoder.transform(
            [[batting_team]]).toarray().flatten())

        bowling_team = request.form['bowling-team']
        # encoding bowling team
        temp_array += list(bowl_team_encoder.transform(
            [[bowling_team]]).toarray().flatten())

        overs = float(request.form['overs'])
        runs = int(request.form['runs'])
        wickets = int(request.form['wickets'])
        last5_runs = int(request.form['last5_runs'])
        last5_wickets = int(request.form['last5_wickets'])

        temp_array = [overs, runs, wickets,
                      last5_runs, last5_wickets] + temp_array

        data = np.array([temp_array]).reshape(1, -1)
        data = scaler.transform(data)  # scaling input features
        predicted_score = int(regressor.predict(data)[0])

        return render_template('result.html', lower_limit=predicted_score-5, upper_limit=predicted_score+10)


if __name__ == '__main__':
    app.run(debug=True)
