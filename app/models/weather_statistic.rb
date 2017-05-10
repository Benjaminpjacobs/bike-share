class WeatherStatistic < ActiveRecord::Base
  belongs_to :date_ref
  belongs_to :city
  
  has_many :trips, through: :date_ref


  validates :max_temperature, presence: true
  validates :mean_temperature, presence: true
  validates :min_temperature, presence: true
  validates :mean_visibility, presence: true
  validates :mean_humidity, presence: true
  validates :mean_wind_speed, presence: true
  validates :precipitation, presence: true
  validates :date_ref_id, presence: true


  def self.create_new(params)
    date = DateRef.find_or_create_by(date: params[:weather][:date_ref_id])
    WeatherStatistic.create(max_temperature: params[:weather][:max_temperature],
                            min_temperature: params[:weather][:min_temperature],
                            mean_temperature: params[:weather][:mean_temperature],
                            mean_visibility: params[:weather][:mean_visibility],
                            mean_humidity: params[:weather][:mean_humidity],
                            mean_wind_speed: params[:weather][:mean_wind_speed],
                            precipitation: params[:weather][:precipitation],
                            date_ref_id: date.id,
                          )
  end

  def self.udpate_record(params)
    date = DateRef.find_or_create_by(date: params[:weather][:date_ref_id])
    WeatherStatistic.update(params[:id],
                  max_temperature: params[:weather][:max_temperature],
                  min_temperature: params[:weather][:min_temperature],
                  mean_temperature: params[:weather][:mean_temperature],
                  mean_visibility: params[:weather][:mean_visibility],
                  mean_humidity: params[:weather][:mean_humidity],
                  mean_wind_speed: params[:weather][:mean_wind_speed],
                  precipitation: params[:weather][:precipitation],
                  date_ref_id: date.id,
                )

  end

  def self.dashboard
    { 
    breakout_avg_max_min_rides_days_high_temp:''
    }

  end

  def self.high_temp
    range = (((WeatherStatistic.minimum(:max_temperature)/10).floor*10)..((WeatherStatistic.maximum(:max_temperature)/10).floor * 10)).step(10).to_a
    range.each_with_index.map do |temp, i|
      if i == 0 || i == (range.length-1)
        next
      else
      {"#{temp-10} - #{temp}" => 
        WeatherStatistic.joins(:trips)
                  .where("mean_temperature between ? and ?", range[i-1], range[i])
                  .group(:date).order('count_id ASC')
                  .count(:id).values
        
      }
      end
    end.compact
  end

  def format(hash)
    hash.map do |ranges| 
      ranges.each do |k, v| 
        if v.empty? 
          next 
        else 
          ranges[k] = [v.max, v.min, (v.inject(:+)/v.length)] 
        end 
      end 
    end
  end
end
