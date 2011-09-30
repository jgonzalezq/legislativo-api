class Proyecto
  include Mongoid::Document
  include Mongoid::Timestamps

  index :id_proyecto_ley
  
  # fields suitable for duplicating on related documents
  def self.basic_fields
    [
      :id_proyecto_ley, :nro_boletin, :titulo, :titulo_sesion, 
      :fecha_ingreso, :iniciativa, :tipo, :camara_origen, :urgencia,
      :etapa, :sub_etapa, :ley, :ley_bcn, :decreto, :decreto_bcn,
      :fecha_publicacion, :id_materia, :nro_interno, :avance,
      :nro_tramitacion, :tramitacion_act, :resumen
    ]
  end
end

class Comision
  include Mongoid::Document
  include Mongoid::Timestamps

  index :id_comision
  
  def self.basic_fields
    [
      :id_comision, :nombre, :tipo, :camara, :contacto_mail, 
      :contacto_tel, :contacto_form, :abogado_secretario, :abogado_ayudante,
      :secretario_ejecutivo
    ]
  end
end

class Parlamentario
  include Mongoid::Document
  include Mongoid::Timestamps
  
  index :id_parlamentario
end

class Votacion
  include Mongoid::Document
  include Mongoid::Timestamps
  
  index :id_votacion
  index :id_proyecto_ley
end

# record information about every API request
class Hit
  include Mongoid::Document
  
  index :created_at
  index :method
  index :sections
  index :user_agent
end